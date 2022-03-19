pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

import "./donation/Donation.sol";
import "./nameBook/NameBook.sol";
import "./alapRegistration/AlapRegistration.sol";

contract UnityViewer is Ownable {
    struct NameInfo {
        address account;
        string name;
    }
    using SafeMath for uint256;

    ERC721 public immutable alap;
    address payable public donation;
    address public nameBook;
    address public alapRegistration;

    constructor(
        address _alap,
        address _donation,
        address _nameBook,
        address _alapRegistration
    ) public {
        alap = ERC721(_alap);
        donation = payable(_donation);
        nameBook = _nameBook;
        alapRegistration = _alapRegistration;
    }

    function alapBalanceOf(address _account) external view returns (uint256) {
        return alap.balanceOf(_account);
    }

    function userAlapIds(
        address _account,
        uint256 _offset,
        uint256 _limit
    ) public view returns (uint256[] memory tokenIds, uint256 count) {
        uint256 total = alap.balanceOf(_account);
        count = _limit <= total.sub(_offset) ? _limit : total.sub(_offset);

        tokenIds = new uint256[](count);
        for (uint256 i = 0; i < count; ++i) {
            tokenIds[i] = alap.tokenOfOwnerByIndex(_account, (total - 1) - (_offset + i));
        }
    }

    function representativeAlapIdOf(address _account) public view returns (uint256) {
        uint256 registredId = getUserAlapId(_account);
        (uint256[] memory ids, ) = userAlapIds(_account, 0, 1);

        return registredId != 0 ? registredId : ids.length != 0 ? ids[0] : 0;
    }

    function klayTopDonatorList()
        public
        view
        returns (Donation.Donator[] memory donatorList, uint256[] memory tokenList)
    {
        uint256 count = Donation(donation).klayTopDonatorLength();
        donatorList = new Donation.Donator[](count);
        tokenList = new uint256[](count);

        for (uint256 i = 0; i < count; ++i) {
            (address account, uint256 amount, uint256 blockNumber) = Donation(donation)
                .klayTopDonator(i);
            donatorList[i] = Donation.Donator(account, amount, blockNumber);
            tokenList[i] = representativeAlapIdOf(account);
        }
    }

    function palaTopDonatorList()
        public
        view
        returns (Donation.Donator[] memory donatorList, uint256[] memory tokenList)
    {
        uint256 count = Donation(donation).palaTopDonatorLength();
        donatorList = new Donation.Donator[](count);
        tokenList = new uint256[](count);

        for (uint256 i = 0; i < count; ++i) {
            (address account, uint256 amount, uint256 blockNumber) = Donation(donation)
                .palaTopDonator(i);
            donatorList[i] = Donation.Donator(account, amount, blockNumber);
            tokenList[i] = representativeAlapIdOf(account);
        }
    }

    function getNamesOf(address[] memory _accounts)
        public
        view
        returns (NameInfo[] memory nameInfos)
    {
        nameInfos = new NameInfo[](_accounts.length);
        for (uint256 i = 0; i < _accounts.length; ++i) {
            nameInfos[i] = NameInfo(_accounts[i], NameBook(nameBook).names(_accounts[i]));
        }
    }

    function getNamingFee() external view returns (uint256) {
        return NameBook(nameBook).fee();
    }

    function getUserAlapId(address _account) public view returns (uint256) {
        return AlapRegistration(alapRegistration).getUserAlapId(_account);
    }

    function setDonation(address _contractAddr) external onlyOwner {
        donation = payable(_contractAddr);
    }

    function setNameBook(address _contractAddr) external onlyOwner {
        nameBook = _contractAddr;
    }

    function setAlapRegistration(address _contractAddr) external onlyOwner {
        alapRegistration = _contractAddr;
    }
}
