// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MockERC20
 *
 * @dev A mock ERC20 token contract.
 */

contract MockERC20 is ERC20 {
    uint256 public constant INITIAL_SUPPLY = 1_000 ether;
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    // Anyone can mint this mock token for test
    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}
