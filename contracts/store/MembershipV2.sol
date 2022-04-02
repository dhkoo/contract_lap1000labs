// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Membership.sol";

contract MembershipV2 is Membership {
    address public target;

    function setTarget(address _target) external {
        target = _target;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        if (target != address(0)) require(from != target && to != target, "NOT_ALLOWED");
    }
}
