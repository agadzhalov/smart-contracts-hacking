// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract AGNft is ERC721 {
    
    address public owner;

    uint256 public s_counter;

    uint256 public constant MAX_TOTAL_SUPPLY = 10000;
    uint256 public constant MINT_PRICE = 0.1 ether;
    
    error AGNft_MaxTotalSupplyExceeded();
    error AGNft_NotExactMintPrice();

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        owner = msg.sender;
        s_counter = 0;
    }

    function mint(address _to) payable external {
        if (MINT_PRICE < msg.value || MINT_PRICE > msg.value) {
            revert AGNft_NotExactMintPrice();
        }
        s_counter++;
        if (s_counter > MAX_TOTAL_SUPPLY) {
            revert AGNft_MaxTotalSupplyExceeded();
        }
        _mint(_to, s_counter);
    }

}