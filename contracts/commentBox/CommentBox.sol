pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

contract CommentBox is OwnableUpgradeable {
    struct Comment {
        address account;
        string content;
        uint256 timestamp;
    }

    address public dev;
    address public feeToken;
    uint256 public fee;

    Comment[] public comments;

    function initialize(address _feeToken, uint256 _fee) public initializer {
        __Ownable_init();
        dev = msg.sender;
        feeToken = _feeToken;
        fee = _fee;
    }

    function leaveComment(string calldata _comment) external virtual {
        if (fee > 0) {
            require(IERC20(feeToken).allowance(msg.sender, address(this)) >= fee, "NOT_APPROVED");
            IERC20(feeToken).transferFrom(msg.sender, dev, fee);
        }
        comments.push(Comment(msg.sender, _comment, block.timestamp));
    }

    function setDev(address _account) external virtual onlyOwner {
        dev = _account;
    }

    function setFeeToken(address _feeTokenAddr) external virtual onlyOwner {
        feeToken = _feeTokenAddr;
    }

    function setFee(uint256 _amount) external virtual onlyOwner {
        fee = _amount;
    }

    function getCommentsLength() external view virtual returns (uint256) {
        return comments.length;
    }
}
