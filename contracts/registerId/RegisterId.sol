pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

contract RegisterId is OwnableUpgradeable {
    address public alap;
    mapping(address => uint256) public alapIds;

    function initialize(address _alap) public initializer {
        __Context_init();
        __Ownable_init();
        alap = _alap;
    }

    function registerId(uint256 _id) external {
        require(IERC721(alap).ownerOf(_id) == msg.sender, "NOT_OWNED");
        alapIds[msg.sender] = _id;
    }

    function getRegisteredId() external view returns (uint256) {
        return alapIds[msg.sender];
    }
}
