// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Pool} from "src/flash-loan-1/Pool.sol";
import {Receiver} from "src/flash-loan-1/Receiver.sol";
import {GreedyReceiver} from "src/flash-loan-1/GreedyReceiver.sol";


/**
@dev run "forge test --match-contract RA2 -vvvvv" 
*/
contract FLTest is Test {

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");

    uint256 constant HUNDRED_ETH = 100 ether;

    Pool pool;
    Receiver receiver;
    GreedyReceiver greedy;

    function setUp() public {
        vm.deal(deployer, HUNDRED_ETH);

        vm.prank(deployer);
        pool = new Pool();
        // send assets to Pool
        address(pool).call{value: HUNDRED_ETH}("");

        vm.prank(user);
        receiver = new Receiver(address(pool));
        greedy = new GreedyReceiver(address(pool));
    }

    function testReceiverReturnsAssets() public {
        vm.prank(user);
        console.log("Receiver before loan: ", address(receiver).balance);
        console.log("Pool before loan: ", address(pool).balance);
        assertEq(address(receiver).balance, 0);
        assertEq(address(pool).balance, HUNDRED_ETH);
        receiver.flashLoan(HUNDRED_ETH);
        console.log("Receiver after loan: ", address(receiver).balance);
        console.log("Pool after loan: ", address(pool).balance);
        assertEq(address(receiver).balance, 0);
        assertEq(address(pool).balance, HUNDRED_ETH);
    }

    function testGreedyReceiverDoesntReturnMoney() public {
        vm.prank(user);
        vm.expectRevert(bytes("receiver can't return the loan"));
        greedy.flashLoan(HUNDRED_ETH);
    }

}