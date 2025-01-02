// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

contract Router {
    address public factory;
    address public WETH;

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }

    function addLiquidity() external {}

    function removeLiquidiry() external {}

    function swapExactTokensForTokens() external {}

    function swapTokensForExactTokens() external {}

    function swapExactETHForTokens() external {}

    function swapTokensForExactETH() external {}
}
