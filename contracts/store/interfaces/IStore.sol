pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface IStore {
    enum Status {
        LIST,
        CANCELLIST,
        SALE
    }

    struct Item {
        address token;
        uint256 tokenId;
        uint256 price;
        uint256 expiredBlockNumber;
    }

    struct Activity {
        address from;
        address to;
        address token;
        uint256 tokenId;
        uint256 price;
        uint256 blockNumber;
        Status status;
    }

    function itemSeller(address token, uint256 tokenId) external view returns (address);

    function userListItems(address account, uint256 index) external view returns (Item memory);

    function userActivities(address account, uint256 index) external view returns (Activity memory);

    function userListItemIndex(
        address account,
        address token,
        uint256 tokenId
    ) external view returns (uint256);

    function userListItemsCount(address account) external view returns (uint256);

    function userActivitiesCount(address account) external view returns (uint256);
}
