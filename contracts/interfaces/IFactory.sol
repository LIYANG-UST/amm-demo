// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

interface IFactory {
    function getPair(address _tokenA, address _tokenB) external view returns (address);
    function getReserves(address _tokenA, address _tokenB) external view returns (uint256 reserveA, uint256 reserveB);

    function createPair(address _tokenA, address _tokenB) external returns (address);

    function pairLocked(address _pair) external view returns (bool);
}
