// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Store is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeMath for uint256;
    using Address for address;

    enum Status {
        LIST,
        CANCELLIST,
        SALE
    }

    struct Item {
        address token;
        uint256 tokenId;
        uint256 price;
        uint256 expiredBlockNumber;
    }

    struct Activity {
        address from;
        address to;
        address token;
        uint256 tokenId;
        uint256 price;
        uint256 blockNumber;
        Status status;
    }

    uint256 public constant MAX_RATIO = 1e4;

    address public dev;
    address public membership;

    uint256 public defaultFeeRatio;
    uint256 public premiumFeeRatio;

    uint256 public GCCount;
    uint256 public GCMaxIter;

    mapping(address => uint256) public gcUserListPointers;

    //seller => Item[]
    //seller => token => tokenId => index
    mapping(address => Item[]) public userListItems;
    mapping(address => mapping(address => mapping(uint256 => uint256))) public userListItemIndex;
    //token => tokenId => seller
    mapping(address => mapping(uint256 => address)) public itemSeller;
    mapping(address => Activity[]) public userActivities;

    event List(
        address indexed seller,
        address indexed token,
        uint256 indexed tokenId,
        uint256 price,
        uint256 expiredBlockNumber
    );
    event CancelList(address indexed seller, address indexed token, uint256 indexed tokenId);
    event CancelListForAdmin(
        address indexed seller,
        address indexed token,
        uint256 indexed tokenId
    );
    event Sale(
        address indexed from,
        address indexed to,
        address token,
        uint256 tokenId,
        uint256 price
    );

    function initialize(
        address _dev,
        uint256 _defaultFeeRatio,
        uint256 _premiumFeeRatio,
        uint256 _GCCount,
        uint256 _GCMaxIter
    ) public virtual initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        dev = _dev;
        defaultFeeRatio = _defaultFeeRatio;
        premiumFeeRatio = _premiumFeeRatio;
        GCCount = _GCCount;
        GCMaxIter = _GCMaxIter;
    }

    receive() external payable {}

    function list(
        address token,
        uint256 tokenId,
        uint256 price,
        uint256 expiredBlockNumber
    ) external virtual {
        require(_tokenOwnerOf(token, tokenId) == msg.sender, "NOT_OWNED_NFT");
        require(IERC721(token).isApprovedForAll(msg.sender, address(this)), "NOT_APPROVED");
        require(expiredBlockNumber > block.number, "EXCEED_EXPIRED_BLOCKNUMBER");
        require(price > 0, "ZERO_PRICE");

        address recordedSeller = itemSeller[token][tokenId];
        if (recordedSeller == msg.sender) {
            uint256 index = userListItemIndex[msg.sender][token][tokenId];
            Item storage item = userListItems[msg.sender][index];
            item.price = price;
            item.expiredBlockNumber = expiredBlockNumber;
        } else {
            _removeSaleItem(recordedSeller, token, tokenId);

            userListItemIndex[msg.sender][token][tokenId] = userListItems[msg.sender].length;
            userListItems[msg.sender].push(Item(token, tokenId, price, expiredBlockNumber));
            itemSeller[token][tokenId] = msg.sender;
        }

        _userListGC(msg.sender);
        userActivities[msg.sender].push(
            Activity(msg.sender, address(0), token, tokenId, price, block.number, Status.LIST)
        );

        emit List(msg.sender, token, tokenId, price, expiredBlockNumber);
    }

    function cancelList(address token, uint256 tokenId) external virtual {
        _cancelList(msg.sender, token, tokenId);
        userActivities[msg.sender].push(
            Activity(msg.sender, address(0), token, tokenId, 0, block.number, Status.CANCELLIST)
        );
        emit CancelList(msg.sender, token, tokenId);
    }

    function cancelListForAdmin(
        address account,
        address token,
        uint256 tokenId
    ) external virtual onlyOwner {
        _cancelList(account, token, tokenId);
        userActivities[msg.sender].push(
            Activity(account, address(0), token, tokenId, 0, block.number, Status.CANCELLIST)
        );
        emit CancelListForAdmin(account, token, tokenId);
    }

    function buy(
        address token,
        uint256 tokenId,
        uint256 maxPrice
    ) external payable virtual nonReentrant {
        address seller = itemSeller[token][tokenId];
        require(msg.sender != seller, "YOU_ARE_OWNER");
        require(IERC721(token).isApprovedForAll(seller, address(this)), "NOT_APPROVED");
        require(_tokenOwnerOf(token, tokenId) == seller, "NOT_OWNED_NFT");

        uint256 index = userListItemIndex[seller][token][tokenId];
        Item memory item = userListItems[seller][index];
        require(item.expiredBlockNumber > block.number, "EXCEED_EXPIRED_TIME");
        require(item.price <= maxPrice, "NOT_SATISFY_PRICE");

        require(item.price <= msg.value, "NOT_ENOUGH_KLAY");

        _removeSaleItem(seller, token, tokenId);

        _settleSale(seller, msg.sender, token, tokenId, item.price);

        userActivities[msg.sender].push(
            Activity(seller, msg.sender, token, tokenId, item.price, block.number, Status.SALE)
        );

        emit Sale(seller, msg.sender, token, tokenId, item.price);
    }

    function setMembership(address membershipAddr) external virtual onlyOwner {
        membership = membershipAddr;
    }

    function setPremiumFeeRatio(uint256 ratio) public virtual onlyOwner {
        premiumFeeRatio = ratio;
    }

    function setdefaultFeeRatio(uint256 ratio) public virtual onlyOwner {
        defaultFeeRatio = ratio;
    }

    function setGCCount(uint256 count) external virtual onlyOwner {
        GCCount = count;
    }

    function setGCMaxIter(uint256 iter) external virtual onlyOwner {
        GCMaxIter = iter;
    }

    function _cancelList(
        address account,
        address token,
        uint256 tokenId
    ) internal virtual {
        require(itemSeller[token][tokenId] == account, "NOT_SELLER");
        _removeSaleItem(account, token, tokenId);
    }

    function _tokenOwnerOf(address token, uint256 tokenId) internal view virtual returns (address) {
        try IERC721(token).ownerOf(tokenId) returns (address owner) {
            return owner;
        } catch {
            return address(0);
        }
    }

    function _userListGC(address account) internal virtual {
        uint256 targetLength = userListItemsCount(account);
        uint256 gcPointer = gcUserListPointers[account];

        if (targetLength == 0) return;

        gcPointer = targetLength <= gcPointer ? 0 : gcPointer;
        uint256 iterCount = targetLength < GCMaxIter ? targetLength : GCMaxIter;
        uint256 removalCount = GCCount;

        while (iterCount > 0 && removalCount > 0) {
            Item memory item = userListItems[account][gcPointer];
            address owner = _tokenOwnerOf(item.token, item.tokenId);

            if (owner != account || item.expiredBlockNumber <= block.number) {
                _removeSaleItem(account, item.token, item.tokenId);
                removalCount--;
            } else {
                gcPointer++;
            }
            targetLength = userListItemsCount(account);
            if (gcPointer > targetLength - 1) {
                gcPointer = 0;
            }
            iterCount--;
        }
        gcUserListPointers[account] = gcPointer;
    }

    function _settleSale(
        address seller,
        address buyer,
        address token,
        uint256 tokenId,
        uint256 price
    ) internal virtual {
        uint256 feeRatio = _calcFeeRatio(seller);
        uint256 fee = price.mul(feeRatio).div(MAX_RATIO);

        payable(dev).transfer(fee);
        payable(seller).transfer(price.sub(fee));
        IERC721(token).transferFrom(seller, buyer, tokenId);
    }

    function _calcFeeRatio(address account) internal view virtual returns (uint256) {
        if (membership == address(0)) return defaultFeeRatio;
        return IERC721(membership).balanceOf(account) > 0 ? premiumFeeRatio : defaultFeeRatio;
    }

    function _removeSaleItem(
        address account,
        address token,
        uint256 tokenId
    ) internal virtual {
        if (itemSeller[token][tokenId] == address(0)) {
            return;
        }
        uint256 lastIndex = userListItems[account].length - 1;
        uint256 index = userListItemIndex[account][token][tokenId];

        if (lastIndex != index) {
            Item memory last = userListItems[account][lastIndex];
            userListItems[account][index] = last;
            userListItemIndex[account][last.token][last.tokenId] = index;
        }
        userListItems[account].pop();
        delete userListItemIndex[account][token][tokenId];
        delete itemSeller[token][tokenId];
    }

    function userListItemsCount(address account) public view virtual returns (uint256) {
        return userListItems[account].length;
    }

    function userActivitiesCount(address account) public view virtual returns (uint256) {
        return userActivities[account].length;
    }
}
