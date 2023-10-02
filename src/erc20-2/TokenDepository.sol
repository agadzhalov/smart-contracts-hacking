// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {rToken} from "./rToken.sol";

/**
 * @title TokensDepository
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract TokensDepository {
    mapping(address => IERC20) public tokens;
    mapping(address => rToken) public receiptTokens;

    rToken public rAave;
    rToken public rUni;
    rToken public rWeth;
    
    modifier tokenIsSupported(address _token) {
        require(address(tokens[_token]) != address(0), "token is not supported");
        _;
    }

    // TODO: Complete this contract functionality
    constructor(address _aave, address _uni, address _weth) {
        // suported tokens
        tokens[_aave] = IERC20(_aave);
        tokens[_uni] = IERC20(_uni);
        tokens[_weth] = IERC20(_weth);

        // deploy receipt tokens
        receiptTokens[_aave] = new rToken(_aave, "receipt Aave", "rAave");
        receiptTokens[_uni] = new rToken(_aave, "receipt uni", "rUni");
        receiptTokens[_weth] = new rToken(_aave, "receipt weth", "rWeth");
    }

    function deposit(address _token, uint256 _amount) external tokenIsSupported(_token) {
        bool success = tokens[_token].transferFrom(msg.sender, address(this), _amount);
        require(success, "transferFrom failed");
        receiptTokens[_token].mint(msg.sender, _amount);
    }

    function withdraw(address _token, uint256 _amount) external tokenIsSupported(_token) {
        receiptTokens[_token].burn(msg.sender, _amount);
        bool success = tokens[_token].transfer(msg.sender, _amount);
        require(success, "transfer failed");
    }

}