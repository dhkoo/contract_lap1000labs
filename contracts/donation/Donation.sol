pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";

contract Donation is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    struct Donator {
        address account;
        uint256 amount;
        uint256 blockNumber;
    }
    event Debug(uint256 index);

    uint256 public constant DISPLAY_COUNT = 10;
    uint256 private constant MAX_VALUE =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;
    address public immutable pala;

    Donator[] public userKlayDonation;
    Donator[] public userPalaDonation;
    mapping(address => uint256) private userKlayDonationIndex;
    mapping(address => uint256) private userPalaDonationIndex;

    Donator[] public klayTopDonator;
    Donator[] public palaTopDonator;

    uint256 public totalKlayAmount;
    uint256 public totalPalaAmount;

    address payable public dev;

    mapping(address => bool) public writers;

    constructor(address _pala) public {
        pala = _pala;
        dev = msg.sender;
        addWriter(msg.sender);
    }

    receive() external payable {}

    function addWriter(address account) public onlyOwner {
        require(!isWriter(account), "account is already writer");
        writers[account] = true;
    }

    function removeWriter(address account) public onlyOwner {
        require(isWriter(account), "account is not writer");
        writers[account] = false;
    }

    function isWriter(address account) public view returns (bool) {
        return writers[account];
    }

    function setDevAccount(address account) external onlyOwner {
        dev = payable(account);
    }

    function setKlayDonator(
        address account,
        uint256 amount,
        uint256 blockNumber
    ) external {
        require(isWriter(msg.sender), "NOT_ALLOWED");
        userKlayDonationIndex[account] = userKlayDonation.length;
        userKlayDonation.push(Donator(account, amount, blockNumber));
        _updateKlayTopDonator(account);
    }

    function setPalaDonator(
        address account,
        uint256 amount,
        uint256 blockNumber
    ) external {
        require(isWriter(msg.sender), "NOT_ALLOWED");
        userPalaDonationIndex[account] = userPalaDonation.length;
        userPalaDonation.push(Donator(account, amount, blockNumber));
        _updatePalaTopDonator(account);
    }

    function donateKLAY() external payable nonReentrant {
        require(msg.value > 0, "ZERO_KLAY");

        dev.transfer(msg.value);
        totalKlayAmount += msg.value;

        if (_isNewKlayDonator(msg.sender)) {
            userKlayDonationIndex[msg.sender] = userKlayDonation.length;
            userKlayDonation.push(Donator(msg.sender, msg.value, block.number));
        } else {
            uint256 index = userKlayDonationIndex[msg.sender];
            Donator storage donator = userKlayDonation[index];
            donator.amount += msg.value;
            donator.blockNumber = block.number;
        }
        _updateKlayTopDonator(msg.sender);
    }

    function donatePALA(uint256 amount) external {
        require(IERC20(pala).allowance(msg.sender, address(this)) >= amount, "NOT_APPROVED");
        require(amount > 0, "ZERO_PALA");

        IERC20(pala).transferFrom(msg.sender, dev, amount);
        totalPalaAmount += amount;

        if (_isNewPalaDonator(msg.sender)) {
            userPalaDonationIndex[msg.sender] = userPalaDonation.length;
            userPalaDonation.push(Donator(msg.sender, amount, block.number));
        } else {
            uint256 index = userPalaDonationIndex[msg.sender];
            Donator storage donator = userPalaDonation[index];
            donator.amount += amount;
            donator.blockNumber = block.number;
        }
        _updatePalaTopDonator(msg.sender);
    }

    function _updateKlayTopDonator(address account) internal {
        if (userKlayDonation.length == 0) return;
        _removeKlayTopDonatorDup(account);

        Donator memory donator = userKlayDonation[userKlayDonationIndex[account]];

        uint256 length = klayTopDonator.length;
        if (length < DISPLAY_COUNT) {
            klayTopDonator.push(donator);
        } else {
            uint256 lowestValue = MAX_VALUE;
            for (uint256 i = 0; i < length; ++i) {
                uint256 amount = klayTopDonator[i].amount;
                if (amount < lowestValue) lowestValue = amount;
            }
            if (donator.amount < lowestValue) return;

            uint256[] memory removeCandidates = new uint256[](length);
            uint256 count;
            for (uint256 i = 0; i < length; ++i) {
                if (klayTopDonator[i].amount == lowestValue) {
                    removeCandidates[count++] = i;
                }
            }
            uint256 target;
            uint256 blockNumber = MAX_VALUE;
            for (uint256 i = 0; i < count; ++i) {
                if (blockNumber > klayTopDonator[removeCandidates[i]].blockNumber) {
                    blockNumber = klayTopDonator[removeCandidates[i]].blockNumber;
                    target = removeCandidates[i];
                }
            }
            uint256 lastIndex = length - 1;
            if (target != lastIndex) {
                klayTopDonator[target] = klayTopDonator[lastIndex];
            }
            klayTopDonator.pop();
            klayTopDonator.push(donator);
        }
    }

    function _updatePalaTopDonator(address account) internal {
        if (userPalaDonation.length == 0) return;
        _removePalaTopDonatorDup(account);

        Donator memory donator = userPalaDonation[userPalaDonationIndex[account]];

        uint256 length = palaTopDonator.length;
        if (length < DISPLAY_COUNT) {
            palaTopDonator.push(donator);
        } else {
            uint256 lowestValue = MAX_VALUE;
            for (uint256 i = 0; i < length; ++i) {
                uint256 amount = palaTopDonator[i].amount;
                if (amount < lowestValue) lowestValue = amount;
            }
            if (donator.amount < lowestValue) return;

            uint256[] memory removeCandidates = new uint256[](length);
            uint256 count;
            for (uint256 i = 0; i < length; ++i) {
                if (palaTopDonator[i].amount == lowestValue) {
                    removeCandidates[count++] = i;
                }
            }
            uint256 target;
            uint256 blockNumber = MAX_VALUE;
            for (uint256 i = 0; i < count; ++i) {
                if (blockNumber > palaTopDonator[removeCandidates[i]].blockNumber) {
                    blockNumber = palaTopDonator[removeCandidates[i]].blockNumber;
                    target = removeCandidates[i];
                }
            }
            uint256 lastIndex = length - 1;
            if (target != lastIndex) {
                palaTopDonator[target] = palaTopDonator[lastIndex];
            }
            palaTopDonator.pop();
            palaTopDonator.push(donator);
        }
    }

    function _removeKlayTopDonatorDup(address account) internal {
        for (uint256 i = 0; i < klayTopDonator.length; ++i) {
            if (account == klayTopDonator[i].account) {
                uint256 lastIndex = klayTopDonator.length - 1;
                if (i != lastIndex) klayTopDonator[i] = klayTopDonator[lastIndex];
                klayTopDonator.pop();
            }
        }
    }

    function _removePalaTopDonatorDup(address account) internal {
        for (uint256 i = 0; i < palaTopDonator.length; ++i) {
            if (account == palaTopDonator[i].account) {
                uint256 lastIndex = palaTopDonator.length - 1;
                if (i != lastIndex) palaTopDonator[i] = palaTopDonator[lastIndex];
                palaTopDonator.pop();
            }
        }
    }

    function _isNewKlayDonator(address account) internal view returns (bool) {
        uint256 index = userKlayDonationIndex[account];
        if (index != 0) return false;

        if (index == 0 && userKlayDonation.length != 0) {
            Donator memory donator = userKlayDonation[index];
            if (donator.account == account) {
                return false;
            }
        }
        return true;
    }

    function _isNewPalaDonator(address account) internal view returns (bool) {
        uint256 index = userPalaDonationIndex[account];
        if (index != 0) return false;

        if (index == 0 && userPalaDonation.length != 0) {
            Donator memory donator = userPalaDonation[index];
            if (donator.account == account) {
                return false;
            }
        }
        return true;
    }

    function userKlayDonationLength() public view returns (uint256) {
        return userKlayDonation.length;
    }

    function userPalaDonationLength() public view returns (uint256) {
        return userPalaDonation.length;
    }

    function klayTopDonatorLength() public view returns (uint256) {
        return klayTopDonator.length;
    }

    function palaTopDonatorLength() public view returns (uint256) {
        return palaTopDonator.length;
    }
}
