pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "../donation/Donation.sol";
import "../donation/DonationViewer.sol";

contract NameBook is Ownable {
    address public dev;
    uint256 public fee;

    address public pala;
    address public donationViewer;

    mapping(address => string) public names;

    constructor(address _pala, address _donationViewerAddr) public {
        dev = msg.sender;
        fee = 1e18;
        pala = _pala;
        donationViewer = _donationViewerAddr;
    }

    function isFreeUser(address account) public view returns (bool) {
        Donation.Donator[] memory klayDonatorList = new Donation.Donator[](10);
        Donation.Donator[] memory palaDonatorList = new Donation.Donator[](10);

        (klayDonatorList, ) = DonationViewer(donationViewer).klayTopDonatorList();
        (palaDonatorList, ) = DonationViewer(donationViewer).palaTopDonatorList();

        for (uint256 i = 0; i < klayDonatorList.length; ++i) {
            if (klayDonatorList[i].account == account) return true;
        }

        for (uint256 i = 0; i < palaDonatorList.length; ++i) {
            if (palaDonatorList[i].account == account) return true;
        }
        return false;
    }

    function setName(string calldata name) external {
        if (!isFreeUser(msg.sender)) {
            require(IERC20(pala).allowance(msg.sender, address(this)) >= fee, "NOT_APPROVED");
            IERC20(pala).transferFrom(msg.sender, dev, fee);
        }
        names[msg.sender] = name;
    }

    function removeName() external {
        if (!isFreeUser(msg.sender)) {
            require(IERC20(pala).allowance(msg.sender, address(this)) >= fee, "NOT_APPROVED");
            IERC20(pala).transferFrom(msg.sender, dev, fee);
        }
        names[msg.sender] = "";
    }

    function setDev(address account) external onlyOwner {
        dev = account;
    }

    function setFee(uint256 amount) external onlyOwner {
        fee = amount;
    }

    function setDonationViewer(address viewer) external onlyOwner {
        donationViewer = viewer;
    }
}
