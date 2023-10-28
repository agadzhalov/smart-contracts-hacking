// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../interfaces/IPair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title FlashSwap
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract FlashSwap {

    IPair pair;
    address token;

    constructor(address _pair) {
        pair = IPair(_pair);
    }

    // TODO: Implement this function
    function executeFlashSwap(address _token, uint256 _amount) external {
        console.log("Before: ", IERC20(_token).balanceOf(address(this)));

        /* ====================================== */
        /*  in order to figure out which 
        /*  token of the pair is the USDC 
        /* ====================================== */
        console.log("token0: ", pair.token0());
        console.log("token1: ", pair.token1());
       
        if (_token == pair.token0()) {
            bytes memory data = abi.encode(_token, msg.sender);
            pair.swap(_amount, 0, address(this), data);
        } else if (_token == pair.token1()) {
            // triggers callback because data is not empty
            pair.swap(0, _amount, address(this), "0xAAA");
        } else {
            revert("Unsupported token");
        }

        console.log("After: ", IERC20(_token).balanceOf(address(this)));
    }

    // TODO: Implement this function
    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external {
        /* ================== SANITY CHECKS ==================== */
        require(msg.sender == address(pair), "only the pair can issue this callback");
        require(sender == address(this), "no permission");

        (address _tokenAddr, address _callerAddr) = abi.decode(data, (address, address));
        IERC20 usdc = IERC20(_tokenAddr);

        console.log("During: ", usdc.balanceOf(address(this)));

        // do whatever with the WETH

        /* ================== RETURN ==================== */
        uint256 fee;
        uint256 toBeReturned;

        if (_tokenAddr == pair.token0()) {
            fee = (amount0 * 3) / 997 + 1;
            toBeReturned = amount0 + fee;
        } else if (_tokenAddr == pair.token1()) {
            fee = (amount1 * 3) / 997 + 1;
            toBeReturned = amount1 + fee;
        }

        usdc.transfer(address(pair), toBeReturned);
    }
}