pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

contract AlapRegistration is OwnableUpgradeable {
    address public alap;
    mapping(address => uint256) public alapIds;

    function initialize(address _alap) public initializer {
        __Ownable_init();
        alap = _alap;
    }

    function registerAlapId(uint256 _id) external {
        require(_ownerOf(_id) == msg.sender, "NOT_OWNED");
        alapIds[msg.sender] = _id;
    }

    function getUserAlapId(address _account) external view returns (uint256) {
        uint256 id = alapIds[_account];
        return _ownerOf(id) == _account ? id : 0;
    }

    function _ownerOf(uint256 _id) internal view returns (address) {
        try IERC721(alap).ownerOf(_id) returns (address owner) {
            return owner;
        } catch {
            return address(0);
        }
    }
}
