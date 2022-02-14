pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";
import "./Donation.sol";
import "../AlapViewer.sol";

contract DonationViewer {
    using SafeMath for uint256;
    using Address for address;

    address payable public donation;
    address public alapViewer;

    constructor(address _donation, address _alapViewer) public {
        donation = payable(_donation);
        alapViewer = _alapViewer;
    }

    function klayTopDonatorList()
        external
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
            (uint256[] memory ids, ) = AlapViewer(alapViewer).userTokenIds(account, 0, 1);
            if (ids.length != 0) tokenList[i] = ids[0];
        }
    }

    function palaTopDonatorList()
        external
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
            (uint256[] memory ids, ) = AlapViewer(alapViewer).userTokenIds(account, 0, 1);
            if (ids.length != 0) tokenList[i] = ids[0];
        }
    }

    function setDonation(address _donation) external {
        donation = payable(_donation);
    }

    function setAlapViewer(address _alapViewer) external {
        alapViewer = _alapViewer;
    }
}
