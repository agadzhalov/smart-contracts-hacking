// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AGToken is ERC20, Ownable {

    address public s_owner;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        s_owner = msg.sender;
    }

    function mint(address _account, uint256 _amount) external onlyOwner {
        _mint(_account, _amount);
    }

}