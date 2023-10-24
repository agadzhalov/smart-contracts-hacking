// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {RealtySale} from "src/replay-attack-2/RealtySale.sol";
import {Attack} from "src/replay-attack-2/Attack.sol";

interface IRealtyToken is IERC721 {
    function lastTokenID() external returns (uint256);

    function maxSupply() external returns (uint256);
}

/**
@dev run "forge test --match-contract RA2 -vvvvv" 
*/
contract TestRA2 is Test {
    RealtySale realtySale;
    IRealtyToken realtyToken;
    Attack attackSale;

    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address attacker = makeAddr("attacker");

    function setUp() public {
        /** SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        vm.deal(user1, 10000 ether);
        vm.deal(user2, 10000 ether);

        // Attacker starts with 1 ETH in balance
        vm.deal(attacker, 1 ether);

        // Deploy RealtySale
        vm.startPrank(deployer);
        realtySale = new RealtySale();
        /**
         * THE FIX IS TO SET ORACLE BECAUSE 
         * OTHERWISE IS address(0) BE AWARE 
         * OF POOR CONFIG
         */
        //realtySale.setOracle(address(this));
        
        // Attach to deployed RealtyToken
        realtyToken = IRealtyToken(realtySale.getTokenContract());
        vm.stopPrank();

        // Buy without sending ETH reverts
        vm.prank(user1);
        vm.expectRevert();
        realtySale.buy();

        // Some users buy tokens (1 ETH each share)
        vm.prank(user1);
        realtySale.buy{value: 1 ether}();
        vm.prank(user2);
        realtySale.buy{value: 1 ether}();

        // 2 ETH in contract
        assertEq(address(realtySale).balance, 2 ether);

        // Buyer got their share token
        assertEq(realtyToken.balanceOf(user1), 1);
        assertEq(realtyToken.balanceOf(user2), 1);
    }

    function testExploit() public {
        /** CODE YOUR SOLUTION HERE */
        vm.startPrank(attacker);
        attackSale = new Attack(address(realtySale));
        attackSale.attack();
        vm.stopPrank();

        /** SUCCESS CONDITIONS */
        // Attacker bought all 98 shares
        assertEq(realtyToken.balanceOf(attacker), 98);
        // No more shares left :(
        assertEq(realtyToken.lastTokenID(), realtyToken.maxSupply());
    }
}