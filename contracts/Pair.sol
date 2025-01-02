// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "./Libraries/Math.sol";

/**
 * @title Pair
 *
 * @dev A trading pair contract.
 */

contract Pair {
    // ********** CONSTANTS ********** //

    // Minimum liquidity locked
    uint256 public constant MINIMUM_LIQUIDITY = 10 ** 3;

    // Token0 and token1 in this pair
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    // ********** STATE VARIABLES ********** //

    // Token amount inside this pool
    uint256 public reserve0;
    uint256 public reserve1;

    // Transfaction fee (can be set by the factory)
    // 10000 = 100%
    // Maximum fee is 10%
    uint256 public fee;

    // We just implement balance related variables for simplicity
    // It's not fully compatible with ERC20 standard
    uint256 public totalSupply;
    mapping(address account => uint256 balance) balanceOf;

    // ********** CONSTRUCTOR ********** //
    constructor(address _token0, address _token1, uint256 _fee) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);

        fee = _fee;
    }

    // ********** MAIN FUNCTIONS ********** //
    function swap(address _tokenIn, uint256 _amountIn) external returns (uint256 amountOut) {
        require(_tokenIn == address(token0) || _tokenIn == address(token1), "Pair: invalid token");
        require(_amountIn > 0, "Pair: invalid amount");

        // Check the token incoming is token0 or token1
        bool isToken0 = _tokenIn == address(token0);
        (IERC20 tokenIn, IERC20 tokenOut, uint256 reserveIn, uint256 reserveOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        // Calculate the amount of tokenOut
        // dx in, dy out
        // (x + dx) * (y - dy) = k & xy = k
        // dy = ydx / (x + dx)
        uint256 amountInWithFee = (_amountIn * (100 - fee)) / 100;
        amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);

        tokenOut.transfer(msg.sender, amountOut);

        // Update the token reserves of this pair
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));

        return amountOut;
    }

    function addLiquidity(uint256 _amount0, uint256 _amount1) external returns (uint256 liquidity) {
        require(_amount0 > 0 && _amount1 > 0, "Pair: invalid amount");

        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        if (reserve0 > 0 || reserve1 > 0) {
            require(reserve0 * _amount1 == reserve1 * _amount0, "Pair: invalid liquidity");
        }

        if (totalSupply == 0) {
            liquidity = Math.sqrt(_amount0 * _amount1 - MINIMUM_LIQUIDITY);
        } else {
            liquidity = Math.min((_amount0 * totalSupply) / reserve0, (_amount1 * totalSupply) / reserve1);
        }

        _mint(msg.sender, liquidity);

        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));
    }

    function removeLiquidity(uint256 _liquidity) external returns (uint256 amount0, uint256 amount1) {
        require(_liquidity > 0 && totalSupply > 0, "Pair: invalid liquidity");

        uint256 currentBalance0 = token0.balanceOf(address(this));
        uint256 currentBalance1 = token1.balanceOf(address(this));

        uint256 amount0 = (_liquidity * currentBalance0) / totalSupply;
        uint256 amount1 = (_liquidity * currentBalance1) / totalSupply;

        require(amount0 > 0 && amount1 > 0, "Pair: invalid amount");

        _burn(msg.sender, _liquidity);

        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);

        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));

        return (amount0, amount1);
    }

    function setFee(uint256 _fee) external {
        require(_fee <= 1000, "Pair: invalid fee");
        fee = _fee;
    }

    // ********** INTERNAL FUNCTIONS ********** //
    function _mint(address _to, uint256 _amount) internal {
        totalSupply += _amount;
        balanceOf[_to] += _amount;
    }

    function _burn(address _from, uint256 _amount) internal {
        totalSupply -= _amount;
        balanceOf[_from] -= _amount;
    }
}
