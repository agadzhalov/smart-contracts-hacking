// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AGNft} from "../../src/erc721-1/AGNft.sol";

contract AGNftTest is Test {
    
    AGNft agNft;
    address public deployer = makeAddr("deployer");
    address public userOne = makeAddr("userOne");

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
        
        assertEq(agNft.balanceOf(deployer), 5);
        vm.stopPrank();

        // 3. Mint 3 Tokens from User1
        hoax(userOne, INITIAL_BALANACE);
        for (uint8 i = 0; i < 3; i++) {
            agNft.mint{value: MINT_PRICE}(userOne);
        }
        assertEq(agNft.balanceOf(userOne), 3);
    }

}