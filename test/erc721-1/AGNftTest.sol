// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AGNft} from "../../src/erc721-1/AGNft.sol";

contract AGNftTest is Test {
    
    AGNft agNft;
    address public deployer = makeAddr("deployer");

    function setUp() public {
        //1. Deploy your contract from the deployer account
        vm.startPrank(deployer);
        agNft = new AGNft("AlexanderGadzhalov", "AGNFT");
        vm.stopPrank();
    }

    function testNft() public {
        // 2. Mint 5 tokens from Deployer
        
        vm.startPrank(deployer);
        vm.deal(deployer, 100 ether);

        console.log("balance", deployer.balance);

        for (uint8 i = 0; i < 5; i++) {
            agNft.mint{value: 0.1 ether}(deployer);
        }

        console.log("balance after", deployer.balance);


        vm.stopPrank();
    }

}