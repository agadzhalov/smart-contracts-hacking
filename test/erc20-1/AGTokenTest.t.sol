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
        vm.stopPrank();
    }

    // 2. Mint 100K tokens to yourself (Deployer)
    function testMint100KTokenToDeployer() public {
        vm.startPrank(OWNER);
        ag.mint(OWNER, ONE_HUNDRED_THOUSAND_TOKENS);
        vm.stopPrank();
        console.log("total amount: ", ag.balanceOf(OWNER));
        assertEq(ag.balanceOf(OWNER), ONE_HUNDRED_THOUSAND_TOKENS);
    }

    //3. Mint 5K tokens to each one of the users
    function testMint5KTokensEachUser() public {
        vm.startPrank(OWNER);
        ag.mint(USER_ONE, FIVE_THOUSAND_TOKENS);
        assertEq(ag.balanceOf(USER_ONE), FIVE_THOUSAND_TOKENS);

        ag.mint(USER_TWO, FIVE_THOUSAND_TOKENS);
        assertEq(ag.balanceOf(USER_TWO), FIVE_THOUSAND_TOKENS);

        ag.mint(USER_THREE, FIVE_THOUSAND_TOKENS);
        assertEq(ag.balanceOf(USER_THREE), FIVE_THOUSAND_TOKENS);
        vm.stopPrank();
    }
}