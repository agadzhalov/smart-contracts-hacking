// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {AGToken} from "../../src/erc20-1/AGToken.sol";

contract AGTokenTest is Test {

    AGToken public ag;

    address public OWNER = makeAddr("owner");
    address public USER_ONE = makeAddr("userOne");
    address public USER_TWO = makeAddr("userTwo");
    address public USER_THREE = makeAddr("userThree");

    uint256 private constant ONE_HUNDRED_THOUSAND_TOKENS = 100000;
    uint256 private constant FIVE_THOUSAND_TOKENS = 5000;

    function setUp() public {
        // 1. Deploy your contract from the deployer account
        vm.startPrank(OWNER);
        ag = new AGToken("AGToken", "AGT");

        // 2. Mint 100K tokens to yourself (Deployer)
        ag.mint(OWNER, ONE_HUNDRED_THOUSAND_TOKENS);

        //3. Mint 5K tokens to each one of the users
        ag.mint(USER_ONE, FIVE_THOUSAND_TOKENS);
        ag.mint(USER_TWO, FIVE_THOUSAND_TOKENS);
        ag.mint(USER_THREE, FIVE_THOUSAND_TOKENS);

        vm.stopPrank();
    }

    //4. Verify with a test that every user has the right amount of tokens
    function testMint5KTokensEachUser() public {
        assertEq(ag.balanceOf(OWNER), ONE_HUNDRED_THOUSAND_TOKENS);
        assertEq(ag.balanceOf(USER_ONE), FIVE_THOUSAND_TOKENS);
        assertEq(ag.balanceOf(USER_TWO), FIVE_THOUSAND_TOKENS);
        assertEq(ag.balanceOf(USER_THREE), FIVE_THOUSAND_TOKENS);
    }

    // 5. Transfer 100 tokens from User2 to User3
    function testTrasnfertTokensFromUserTwoToUserThree() public {
        vm.startPrank(USER_TWO);
        ag.transfer(USER_THREE, 100);
        uint256 expectedAmount = FIVE_THOUSAND_TOKENS + 100;
        assertEq(ag.balanceOf(USER_THREE), expectedAmount);
        vm.stopPrank();
    }
}