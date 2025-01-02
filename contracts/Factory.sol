// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

import {Pair} from "./Pair.sol";

/**
 * @title Factory
 *
 * @dev The factory contract to deploy trading pairs.
 *      Trading pair contract: ./Pair.sol
 */

contract Factory {
    function deployPair(address _tokenA, address _tokenB, uint256 _fee) external returns (address) {
        require(_fee <= 1000, "Factory: invalid fee");
        return address(new Pair(_tokenA, _tokenB, _fee));
    }

    function setFee(address _pair, uint256 _fee) external {
        Pair(_pair).setFee(_fee);
    }
}
