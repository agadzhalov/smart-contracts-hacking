// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DonationMaster} from "../../src/unchecked-returns-1/DonationMaster.sol";
import {MultiSigSafe} from "../../src/unchecked-returns-1/MultiSigSafe.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


/**
 * Unchecked Returns Exercise 1
 * All the tests should pass if you run
 * 
 * @dev run "forge test --match-contract TestUR1 -vvv"
 */
contract TestUR1 is Test {

    address private deployer;
    address private user;
    address private userOne;
    address private userTwo;
    address private userThree;

    DonationMaster donationMaster;
    MultiSigSafe multisig;

    uint256 private constant ONE_ETH = 1 ether; // 1 ETH
    uint256 private constant HUNDRED_ETH = 100 ether; // 100 ETH
    uint256 private constant THOUSAND_ETH = 1000 ether; // 1000 ETH

    /** SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
    function setUp() public {
        // create the accounts
        deployer = makeAddr("deployer");
        user = makeAddr("user");
        userOne = makeAddr("userOne");
        userTwo = makeAddr("userTwo");
        userThree = makeAddr("userThree");

        // loading some ETH to deployer
        vm.deal(deployer, HUNDRED_ETH);

        vm.startPrank(deployer);
        // Deploy DonationMaster contract by deployer
        donationMaster = new DonationMaster();

        // Deploy MultiSigSafe contract (2 signatures out of 3)
        address[] memory signers = new address[](3);
        signers[0] = userOne;
        signers[1] = userTwo;
        signers[2] = userThree;
        multisig = new MultiSigSafe(signers, 2);
        vm.stopPrank();
    }

    function testDonation() public {
        /* SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        vm.startPrank(deployer);

        // New donation works
        donationMaster = new DonationMaster();
        donationMaster.newDonation(address(multisig), HUNDRED_ETH);
        uint donationId = donationMaster.donationsNo() - 1;

        // Donating to multisig wallet works
        donationMaster.donate{value: ONE_ETH}(donationId);

        // Donating to multisig wallet works
        (uint id, address to, uint goal, uint donated) = donationMaster.donations(donationId);
        
        assertEq(id, donationId);
        assertEq(to, address(multisig));
        assertEq(goal, HUNDRED_ETH);
        assertEq(donated, ONE_ETH);

        vm.expectRevert();
        // Too big donation fails (goal reached)
        donationMaster.donate{value: THOUSAND_ETH}(donationId);

        /* CODE YOUR SOLUTION HERE */
        /* Write the corrects here */
        // catch first bug - send returns boolean and we don't check if it is true
        // MultiSigSafe doesn't implement fallback/receive function and get receive any ETH
        assertNotEq(address(multisig).balance, ONE_ETH);
    }

}