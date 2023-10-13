// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {CryptoEmpireGame} from "../../src/reentrancy-4/CryptoEmpireGame.sol";
import {CryptoEmpireToken} from "../../src/reentrancy-4/CryptoEmpireToken.sol";
import {Attack} from "../../src/reentrancy-4/Attack.sol";
import {NftId} from "../../src/reentrancy-4/GameItems.sol";

contract Reentrancy4Test is Test {

    CryptoEmpireGame game;
    CryptoEmpireToken token;
    Attack attack;

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");
    address userTwo = makeAddr("userTwo");
    address attacker = makeAddr("attacker");

    uint256 constant INIT_BALANCE = 100 * 1e18;
    uint256 constant NFT_AMOUNT = 20;

    function setUp() public {
        vm.deal(deployer, INIT_BALANCE);
        vm.deal(attacker, INIT_BALANCE);

        vm.startPrank(deployer);
        token = new CryptoEmpireToken();
        game = new CryptoEmpireGame(address(token));

        token.mint(user, 1, NftId.HELMET);
        token.mint(userTwo, 1, NftId.SWORD);
        token.mint(attacker, 1, NftId.ARMOUR);

        token.mint(address(game), NFT_AMOUNT, NftId.HELMET);
        token.mint(address(game), NFT_AMOUNT, NftId.SWORD);
        token.mint(address(game), NFT_AMOUNT, NftId.ARMOUR);
        token.mint(address(game), NFT_AMOUNT, NftId.SHIELD);
        token.mint(address(game), NFT_AMOUNT, NftId.CROSSBOW);
        token.mint(address(game), NFT_AMOUNT, NftId.DAGGER);

        vm.stopPrank();
    }

    function testReentrancyFour() public {
        vm.startPrank(attacker);
        attack = new Attack(address(game));
        token.safeTransferFrom(attacker, address(attack), 2, 1, "");
        assertEq(token.balanceOf(address(attack), 2), 1);
        attack.attack();
        console.log("stolen", token.balanceOf(address(attack), 2) - 1);
        assertTrue(token.balanceOf(address(attack), 2) > 20);
        vm.stopPrank();
    }
}