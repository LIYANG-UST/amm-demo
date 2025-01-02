// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20("Wrapped Ether", "WETH") {
    event WETHMinted(address indexed account, uint256 amount);
    constructor() {
        _mint(msg.sender, 1_000 ether);
    }

    // Transfer ETH to this contract to mint WETH
    function mint() external payable {
        _mint(msg.sender, msg.value);
        emit WETHMinted(msg.sender, msg.value);
    }
}
