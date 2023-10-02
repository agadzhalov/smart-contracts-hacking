// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {AGToken} from "../../src/erc20-1/AGToken.sol";

contract AGTokenTest is Test {

    AGToken public ag;

    address public OWNER = makeAddr("owner");

    uint256 private constant ONE_HUNDRED_TOKENS = 100000;

    function setUp() public {
        // 1. Deploy your contract from the deployer account
        vm.startPrank(OWNER);
        ag = new AGToken("AGToken", "AGT");
        vm.stopPrank();
    }

    // 2. Mint 100K tokens to yourself (Deployer)
    function testMint100KTokenToDeployer() public {
        vm.startPrank(OWNER);
        ag.mint(OWNER, ONE_HUNDRED_TOKENS);
        vm.stopPrank();
        console.log("total amount: ", ag.balanceOf(OWNER));
        assertEq(ag.balanceOf(OWNER), ONE_HUNDRED_TOKENS);
    }

}