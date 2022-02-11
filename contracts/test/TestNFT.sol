pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Burnable.sol";
import "openzeppelin-solidity/contracts/utils/Strings.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

contract TestNFT is ERC721Burnable, Ownable {
    using Strings for uint256;
    uint256 public constant MAX_SUPPLY = 10000;

    mapping(address => bool) public minters;

    modifier onlyMinter() {
        require(isMinter(msg.sender), "NOT_MINTER!");
        _;
    }

    constructor() public ERC721("Test NFT", "TEST") {
        addMinter(msg.sender);
    }

    function mint(address to, string memory tokenURI)
        public
        onlyMinter
        returns (uint256)
    {
        require(totalSupply() < MAX_SUPPLY, "EXCEED_MAX_SUPPLY!");

        uint256 id = totalSupply() + 1;
        _mint(to, id);
        setTokenURI(id, tokenURI);

        return id;
    }

    function bulkMint(
        address to,
        uint256 count,
        string memory prefix,
        string memory postfix
    ) public onlyMinter {
        for (uint256 i = 0; i < count; ++i) {
            uint256 id = totalSupply() + 1;
            string memory tokenURI = string(
                abi.encodePacked(prefix, id.toString(), postfix)
            );
            _mint(to, id);
            setTokenURI(id, tokenURI);
        }
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI)
        public
        onlyMinter
    {
        _setTokenURI(tokenId, tokenURI);
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

    function bulkTransfer(address[] calldata tos, uint256[] calldata ids)
        external
    {
        for (uint256 i = 0; i < ids.length; ++i) {
            transferFrom(msg.sender, tos[i], ids[i]);
        }
    }
}
