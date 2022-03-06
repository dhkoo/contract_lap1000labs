pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "./NameBook.sol";

contract NameBookViewer is Ownable {
    struct NameInfo {
        address account;
        string name;
    }

    address public nameBook;

    constructor(address _nameBook) public {
        nameBook = _nameBook;
    }

    function getNames(address[] memory accounts) public view returns (NameInfo[] memory nameInfos) {
        nameInfos = new NameInfo[](accounts.length);
        for (uint256 i = 0; i < accounts.length; ++i) {
            nameInfos[i] = NameInfo(accounts[i], NameBook(nameBook).names(accounts[i]));
        }
    }

    function getFee() external view returns (uint256) {
        return NameBook(nameBook).fee();
    }

    function setNameBook(address contractAddr) external onlyOwner {
        nameBook = contractAddr;
    }
}
