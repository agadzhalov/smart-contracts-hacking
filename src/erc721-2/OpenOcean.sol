// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.18;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title OpenOcean
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract OpenOcean {

    // TODO: Complete this contract functionality
    // TODO: Constants
    uint256 public constant MAX_PRICE = 100 ether;

    // struct which represents an erc721 item that is on sale
    struct Item {
        uint256 itemId;
        address collectionContract;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool isSold;
    }

    // TODO: State Variables and Mappings
    uint256 public itemsCounter;
    mapping(uint256 itemId => Item item) public listedItems;

    constructor() {}

    // TODO: List item function
    // 1. Make sure params are correct
    // 2. Increment itemsCounter
    // 3. Transfer token from sender to the contract
    // 4. Add item to listedItems mapping
    function listItem(address _collection, uint256 _tokenId, uint256 _price) external {
        require(_collection != address(0), "address 0");
        require(_price != 0 && _price <= MAX_PRICE, "price error");
        require(msg.sender == IERC721(_collection).ownerOf(_tokenId), "user is not the owner");

        itemsCounter += 1;
        IERC721(_collection).transferFrom(msg.sender, address(this), _tokenId);
        listedItems[itemsCounter] = Item(itemsCounter, _collection,_tokenId, _price, payable(msg.sender), false);
    }

    // TODO: Purchase item function 
    // 1. Check that item exists and not sold
    // 2. Check that enough ETH was paid
    // 3. Change item status to "sold"
    // 4. Transfer NFT to buyer
    // 5. Transfer ETH to seller
    function purchase(uint256 _itemId) external payable {
        require(listedItems[_itemId].isSold != true, "item is sold");
        require (msg.value == listedItems[_itemId].price, "wrong price");
        listedItems[_itemId].isSold = true;
        IERC721(listedItems[_itemId].collectionContract).transferFrom(address(this), msg.sender, listedItems[_itemId].tokenId);
        (bool sentEth, ) = listedItems[_itemId].seller.call{value: listedItems[_itemId].price}("");
        require(sentEth, "unsuccessful transfer of ETH to seller");
    }

    function getItemById(uint256 _itemId) external view returns(Item memory) {
        return listedItems[_itemId];
    }
    
}