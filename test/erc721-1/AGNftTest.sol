// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {AGNft} from "../../src/erc721-1/AGNft.sol";

contract AGNftTest is Test {
    
    AGNft agNft;
    address public deployer = makeAddr("deployer");
    address public userOne = makeAddr("userOne");
    address public userTwo = makeAddr("userTwo");

    uint256 private constant INITIAL_BALANACE = 100 ether;
    uint256 private constant MINT_PRICE = 0.1 ether;

    function setUp() public {
        //1. Deploy your contract from the deployer account
        vm.startPrank(deployer);
        agNft = new AGNft("AlexanderGadzhalov", "AGNFT");
        vm.stopPrank();
    }

    function testNft() public {
        // 2. Mint 5 tokens from Deployer
        vm.startPrank(deployer);
        vm.deal(deployer, INITIAL_BALANACE);

        for (uint8 i = 0; i < 5; i++) {
            agNft.mint{value: MINT_PRICE}(deployer);
        }
        vm.stopPrank();

        // 3. Mint 3 Tokens from User1
        hoax(userOne, INITIAL_BALANACE);
        for (uint8 i = 0; i < 3; i++) {
            agNft.mint{value: MINT_PRICE}(userOne);
        }

        //4. Test that every account has the right amount of tokens
        assertEq(agNft.balanceOf(deployer), 5);
        assertEq(agNft.balanceOf(userOne), 3);

        //5. Transfer 1 token from User1 to User2 (Token ID 6)
        vm.startPrank(userOne);
        agNft.safeTransferFrom(userOne, userTwo, 6, "");
        vm.stopPrank();

        //6. Make sure that the token that was transfered is now owned by User2
        assertEq(userTwo, agNft.ownerOf(6));

        //7. From Deployer: approve User1 to spend one of the tokens (Token ID 3)
        vm.startPrank(deployer);
        agNft.approve(userOne, 3);
        vm.stopPrank();

        //8. Test that User1 has the right approval that was granted by the Deployer
        assertEq(agNft.getApproved(3), userOne);

        //9. From User1: transfer to yourself the token that was approved by the Deployer
        vm.startPrank(userOne);
        agNft.safeTransferFrom(deployer, userOne, 3, "");
        vm.stopPrank();
        // 10. Test that User1 owns the transfered token
        assertEq(userOne, agNft.ownerOf(3));

        //11. Test that every user has the right amount of tokens
        assertEq(agNft.balanceOf(deployer), 4);
        assertEq(agNft.balanceOf(userOne), 3);
        assertEq(agNft.balanceOf(userTwo), 1);
    }

}