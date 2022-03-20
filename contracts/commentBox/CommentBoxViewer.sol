pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";

import "./CommentBox.sol";

contract CommentBoxViewer is Ownable {
    struct Comment {
        address account;
        string content;
    }
    using SafeMath for uint256;

    address public commentBox;

    constructor(address _commentBox) public {
        commentBox = _commentBox;
    }

    function getComments(uint256 _number)
        public
        view
        returns (CommentBox.Comment[] memory comments, uint256[] memory indices)
    {
        uint256 len = CommentBox(commentBox).getCommentsLength();
        uint256 count = len > _number ? _number : len;

        comments = new CommentBox.Comment[](_number);
        indices = new uint256[](_number);
        uint256 index;
        while (count > 0) {
            (address account, string memory content, uint256 timestamp) = CommentBox(commentBox)
                .comments(len - index - 1);
            comments[index] = CommentBox.Comment(account, content, timestamp);
            indices[index] = len - index - 1;
            ++index;
            --count;
        }
    }

    function setCommentBox(address _contractAddr) external onlyOwner {
        commentBox = _contractAddr;
    }
}
