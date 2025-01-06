// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

import {RoleAccessUpgradeable} from "./access-control/RoleAccessUpgradeable.sol";
import {IFactory} from "./interfaces/IFactory.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Router is RoleAccessUpgradeable {
    bytes32 public constant PARAMETER_SETTER_ROLE = keccak256("PARAMETER_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    address public factory;
    address public WETH;

    // constructor(address _factory, address _WETH) {
    //     factory = _factory;
    //     WETH = _WETH;

    //     // Default admin roles will control these two roles
    //     _setRoleAdmin(PARAMETER_SETTER_ROLE, DEFAULT_ADMIN_ROLE);
    //     _setRoleAdmin(PAUSER_ROLE, DEFAULT_ADMIN_ROLE);
    // }

    function initialize(address _factory, address _WETH) public initializer {
        __RoleAccess_init();

        factory = _factory;
        WETH = _WETH;

        // Default admin roles will control these two roles
        _setRoleAdmin(PARAMETER_SETTER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(PAUSER_ROLE, DEFAULT_ADMIN_ROLE);
    }

    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _amountADesired,
        uint256 _amountBDesired,
        uint256 _amountAMin,
        uint256 _amountBMin
    ) external {
        // Create a new pair if not exists
        if (IFactory(factory).getPair(_tokenA, _tokenB) == address(0)) {
            IFactory(factory).createPair(_tokenA, _tokenB);
        }

        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountADesired);
    }

    function removeLiquidiry() external {}

    function swapExactTokensForTokens() external {}

    function swapTokensForExactTokens() external {}

    function swapExactETHForTokens() external {}

    function swapTokensForExactETH() external {}

    // ********** EMERGENCY FUNCTIONS ********** //
    function pause() external {}
}
