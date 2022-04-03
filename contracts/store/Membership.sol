pragma solidity ^0.6.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Membership is ERC721BurnableUpgradeable, OwnableUpgradeable {
    uint256 private _lastTokenId;
    uint256 public constant MAX_SUPPLY = 10000;

    mapping(address => bool) public minters;

    modifier onlyMinter() {
        require(isMinter(msg.sender), "NOT_MINTER!");
        _;
    }

    function initialize(uint256 _startId) public virtual initializer {
        __Ownable_init();
        __ERC721_init("LAP MEMBERSHIP", "LAPM");
        __ERC721Burnable_init();
        _lastTokenId = _startId;
        addMinter(msg.sender);
    }

    function mint(address to, string memory tokenURI) public virtual onlyMinter returns (uint256) {
        require(totalSupply() < MAX_SUPPLY, "EXCEED_MAX_SUPPLY!");

        uint256 id = _generateTokenId();
        _mint(to, id);
        _setTokenURI(id, tokenURI);

        return id;
    }

    function mintId(
        address to,
        uint256 id,
        string memory tokenURI
    ) public virtual onlyMinter returns (uint256) {
        require(totalSupply() < MAX_SUPPLY, "EXCEED_MAX_SUPPLY!");

        _mint(to, id);
        _setTokenURI(id, tokenURI);

        return id;
    }

    function bulkMint(address to, uint256 count) public virtual onlyMinter {
        for (uint256 i = 0; i < count; ++i) {
            require(totalSupply() < MAX_SUPPLY, "EXCEED_MAX_SUPPLY!");
            uint256 id = _generateTokenId();
            _mint(to, id);
        }
    }

    function _generateTokenId() internal returns (uint256) {
        return ++_lastTokenId;
    }

    function addMinter(address account) public virtual onlyOwner {
        require(!isMinter(account), "ALREADY_MINTER");
        minters[account] = true;
    }

    function removeMinter(address account) public virtual onlyOwner {
        require(isMinter(account), "NOT_MINTER");
        minters[account] = false;
    }

    function isMinter(address account) public view virtual returns (bool) {
        return minters[account];
    }

    function bulkTransfer(address[] calldata tos, uint256[] calldata ids) external virtual {
        for (uint256 i = 0; i < ids.length; ++i) {
            transferFrom(msg.sender, tos[i], ids[i]);
        }
    }
}
