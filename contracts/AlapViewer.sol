pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract AlapViewer {
    using SafeMath for uint256;

    ERC721 public immutable alap; 

    constructor(address _alap) public {
        alap = ERC721(_alap);
    }

    function balanceOf(address account) external view returns (uint256) {
        return alap.balanceOf(account);
    }

    function userTokenIds(
        address account,
        uint256 offset,
        uint256 limit) external view returns(
        uint256[] memory tokenIds,
        uint256 count) 
    {
        uint256 total = alap.balanceOf(account);
        count = limit <= total.sub(offset) ? limit : total.sub(offset);

        tokenIds = new uint256[](count);
        for(uint256 i = 0; i < count; ++i) {
            tokenIds[i] = alap.tokenOfOwnerByIndex(account, (total-1) - (offset+i));
        }
    }
}
