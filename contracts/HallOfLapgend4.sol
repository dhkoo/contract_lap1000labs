pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

contract HallOfLapgend4 is ERC721, Ownable {
    uint256 private _lastTokenId = 0;

    mapping(address => bool) public minters;

    modifier onlyMinter() {
        require(isMinter(msg.sender), "NOT_MINTER!");
        _;
    }

    constructor() public ERC721("Hall of Lapgend #4", "LAP#4") {
        addMinter(msg.sender);
    }

    function mint(address to, string memory tokenURI) public onlyMinter returns (uint256) {
        uint256 id = _generateTokenId();
        _mint(to, id);
        _setTokenURI(id, tokenURI);

        return id;
    }

    function burn(uint256 tokenId) external onlyMinter {
        _burn(tokenId);
    }

    function setTokenURI(uint256 tokenId, string calldata tokenURI) external onlyMinter {
        _setTokenURI(tokenId, tokenURI);
    }

    function _generateTokenId() internal returns (uint256) {
        return ++_lastTokenId;
    }

    function addMinter(address account) public onlyOwner {
        require(!isMinter(account), "ALREADY_MINTER");
        minters[account] = true;
    }

    function removeMinter(address account) public onlyOwner {
        require(isMinter(account), "NOT_MINTER");
        minters[account] = false;
    }

    function isMinter(address account) public view returns (bool) {
        return minters[account];
    }

    function bulkTransfer(address[] calldata tos, uint256[] calldata ids) external {
        for (uint256 i = 0; i < ids.length; ++i) {
            transferFrom(msg.sender, tos[i], ids[i]);
        }
    }
}
