pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./NameBook.sol";

contract NameBookViewer {
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
}
