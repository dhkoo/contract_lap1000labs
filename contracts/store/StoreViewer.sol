// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/introspection/ERC165.sol";

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

import "./interfaces/IStore.sol";

contract StoreViewer is Ownable {
    using SafeMath for uint256;
    using Address for address;

    enum TokenType {
        NONE,
        NFT,
        NFT_ENUMERABLE
    }

    struct NFT {
        string name;
        string symbol;
        uint256 totalSupply;
    }

    struct NFTMetadata {
        uint256 id;
        string tokenURI;
        address owner;
    }

    address payable public store;
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;
    address public constant KLAY = address(0);

    constructor(address payable _store) public {
        store = _store;
    }

    function setStore(address payable storeAddr) public onlyOwner {
        store = storeAddr;
    }

    function getUserActivities(
        address account,
        uint256 offset,
        uint256 limit
    )
        external
        view
        returns (
            IStore.Activity[] memory activities,
            uint256 count,
            uint256 total
        )
    {
        total = IStore(store).userActivitiesCount(account);
        count = limit <= total.sub(offset) ? limit : total.sub(offset);
        activities = new IStore.Activity[](count);

        for (uint256 i = 0; i < count; ++i) {
            activities[i] = IStore(store).userActivities(account, offset + i);
        }
    }

    function getItemSeller(address token, uint256 tokenId) public view returns (address) {
        address itemOwner = getTokenOwner(token, tokenId);
        address recordedSeller = IStore(store).itemSeller(token, tokenId);

        if (itemOwner != recordedSeller) return address(0);
        if (!hasUserListItem(itemOwner, token, tokenId)) return address(0);

        uint256 index = IStore(store).userListItemIndex(recordedSeller, token, tokenId);
        IStore.Item memory item = IStore(store).userListItems(recordedSeller, index);
        if (item.expiredBlockNumber <= block.number) {
            return address(0);
        }
        return IStore(store).itemSeller(token, tokenId);
    }

    function getItemSellerList(
        address token,
        uint256 offset,
        uint256 limit
    )
        external
        view
        returns (
            address[] memory sellerList,
            uint256 count,
            uint256 total
        )
    {
        total = ERC721(token).totalSupply();
        count = limit <= total.sub(offset) ? limit : total.sub(offset);
        sellerList = new address[](count);

        for (uint8 i = 0; i < count; ++i) {
            sellerList[i] = getItemSeller(token, offset + i);
        }
    }

    function getUserListItem(
        address account,
        address token,
        uint256 tokenId
    ) public view returns (IStore.Item memory) {
        IStore.Item memory item;
        if (getTokenOwner(token, tokenId) == account) {
            if (!hasUserListItem(account, token, tokenId)) return item;

            uint256 index = IStore(store).userListItemIndex(account, token, tokenId);
            item = IStore(store).userListItems(account, index);
        }
        return item;
    }

    function getUserListItems(
        address account,
        uint256 offset,
        uint256 limit,
        bool onlyValid
    )
        external
        view
        returns (
            IStore.Item[] memory items,
            uint256 count,
            uint256 total
        )
    {
        total = IStore(store).userListItemsCount(account);
        count = limit <= total.sub(offset) ? limit : total.sub(offset);
        items = new IStore.Item[](count);

        for (uint8 i = 0; i < count; ++i) {
            IStore.Item memory item = IStore(store).userListItems(account, offset + i);
            if (getTokenOwner(item.token, item.tokenId) != account) {
                continue;
            }
            if (onlyValid && item.expiredBlockNumber <= block.number) {
                continue;
            }
            items[i] = item;
        }
    }

    function hasUserListItem(
        address account,
        address token,
        uint256 tokenId
    ) public view returns (bool) {
        uint256 index = IStore(store).userListItemIndex(account, token, tokenId);
        if (index != 0) return true;
        if (index == 0 && IStore(store).userListItemsCount(account) != 0) {
            IStore.Item memory item = IStore(store).userListItems(account, index);
            if (item.token == token && item.tokenId == tokenId) {
                return true;
            }
        }
        return false;
    }

    function getNFT(address token) public view returns (NFT memory nft) {
        ERC721 erc721 = ERC721(token);
        nft = NFT({
            name: erc721.name(),
            symbol: erc721.symbol(),
            totalSupply: erc721.totalSupply()
        });
    }

    function getNFTList(
        address token,
        uint256 offset,
        uint256 limit
    )
        public
        view
        returns (
            NFTMetadata[] memory tokenList,
            uint256 count,
            uint256 total
        )
    {
        ERC721 nft = ERC721(token);
        total = nft.totalSupply();

        count = limit <= total.sub(offset) ? limit : total.sub(offset);
        tokenList = new NFTMetadata[](count);

        for (uint256 i = 0; i < count; ++i) {
            uint256 tokenId = nft.tokenByIndex(offset + i);
            tokenList[i] = NFTMetadata({
                id: tokenId,
                tokenURI: nft.tokenURI(tokenId),
                owner: nft.ownerOf(tokenId)
            });
        }
    }

    function getNFTListOf(
        address token,
        address account,
        uint256 offset,
        uint256 limit
    )
        public
        view
        returns (
            NFTMetadata[] memory tokenList,
            uint256 count,
            uint256 total
        )
    {
        ERC721 nft = ERC721(token);
        total = nft.balanceOf(account);

        count = limit <= total.sub(offset) ? limit : total.sub(offset);
        tokenList = new NFTMetadata[](count);

        for (uint256 i = 0; i < count; ++i) {
            uint256 tokenId = nft.tokenOfOwnerByIndex(account, offset + i);
            tokenList[i] = NFTMetadata({
                id: tokenId,
                tokenURI: nft.tokenURI(tokenId),
                owner: account
            });
        }
    }

    function checkType(address token) public view returns (TokenType) {
        if (!token.isContract()) return TokenType.NONE;
        if (isERC721(token) && isERC721Enumerable(token)) return TokenType.NFT_ENUMERABLE;
        if (isERC721(token)) return TokenType.NFT;
        if (!hasName(token)) return TokenType.NONE;
        if (!hasSymbol(token)) return TokenType.NONE;
        if (hasBaseURI(token)) return TokenType.NFT;
        return TokenType.NONE;
    }

    function isERC721(address token) internal view returns (bool) {
        try ERC165(token).supportsInterface(_INTERFACE_ID_ERC721) returns (bool isSupport) {
            return isSupport;
        } catch {
            return false;
        }
    }

    function isERC721Enumerable(address token) internal view returns (bool) {
        try ERC165(token).supportsInterface(_INTERFACE_ID_ERC721_ENUMERABLE) returns (
            bool isSupport
        ) {
            return isSupport;
        } catch {
            return false;
        }
    }

    function hasName(address token) internal view returns (bool) {
        try ERC721(token).name() returns (string memory) {
            return true;
        } catch {
            return false;
        }
    }

    function hasSymbol(address token) internal view returns (bool) {
        try ERC721(token).symbol() returns (string memory) {
            return true;
        } catch {
            return false;
        }
    }

    function hasBaseURI(address token) internal view returns (bool) {
        try ERC721(token).baseURI() returns (string memory) {
            return true;
        } catch {
            return false;
        }
    }

    function getTokenOwner(address token, uint256 tokenId) public view returns (address) {
        try ERC721(token).ownerOf(tokenId) returns (address owner) {
            return owner;
        } catch {
            return address(0);
        }
    }
}
