// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "src/dos-2/Auction.sol";
import {Attack} from "src/dos-2/Attack.sol";

contract Dos2Test is Test {
    Auction auction;
    Attack attackAuction;

    uint constant USER1_FIRST_BID = 5 ether;
    uint constant USER2_FIRST_BID = 6.5 ether;

    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(deployer, 100 ether);
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.deal(attacker, 100 ether);

        vm.prank(deployer);
        auction = new Auction();

        vm.prank(user1);
        auction.bid{value: USER1_FIRST_BID}();
        vm.prank(user2);
        auction.bid{value: USER2_FIRST_BID}();

        assertEq(auction.highestBid(), USER2_FIRST_BID);
        assertEq(auction.currentLeader(), address(user2));
    }

    function test_Attack() public {
        /** CODE YOUR SOLUTION HERE */

        vm.startPrank(attacker);
        attackAuction = new Attack(address(auction));
        attackAuction.attack{value: 9 ether}();
        vm.stopPrank();
        /** SUCCESS CONDITIONS */
        // Current highest bid
        uint highestBid = auction.highestBid();

        // Even though User1 bids highestBid * 3, transaction is reverted
        vm.expectRevert();
        vm.prank(user1);
        auction.bid{value: highestBid * 3}();

        // User1 and User2 are not currentLeader
        assertEq(auction.currentLeader() != address(user1), true);
        assertEq(auction.currentLeader() != address(user2), true);
    }
}