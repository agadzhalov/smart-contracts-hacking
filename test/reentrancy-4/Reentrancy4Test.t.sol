// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {CryptoEmpireGame} from "../../src/reentrancy-4/CryptoEmpireGame.sol";
import {CryptoEmpireToken} from "../../src/reentrancy-4/CryptoEmpireToken.sol";
import {NftId} from "../../src/reentrancy-4/GameItems.sol";

contract Reentrancy4Test is Test {

    CryptoEmpireGame game;
    CryptoEmpireToken token;

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

        vm.stopPrank();
    }
}