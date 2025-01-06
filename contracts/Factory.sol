// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

import {Pair} from "./Pair.sol";
import {RoleAccessUpgradeable} from "./access-control/RoleAccessUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title Factory
 *
 * @dev The factory contract to deploy trading pairs.
 *      Trading pair contract: ./Pair.sol
 */

contract Factory is OwnableUpgradeable, RoleAccessUpgradeable {
    bytes32 public constant PARAMETER_SETTER_ROLE = keccak256("PARAMETER_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    // ********** STATE VARIABLES ********** //
    mapping(address tokenA => mapping(address tokenB => address)) public pairs;
    mapping(address pair => bool isLocked) public pairLocked;

    // ********** EVENTS ********** //
    event PairCreated(address indexed tokenA, address indexed tokenB, address pair);
    event PairLocked(address indexed pair);
    event PairUnlocked(address indexed pair);
    event PairFeeChanged(address indexed pair, uint256 fee);

    // ********** CONSTRUCTOR ********** //
    function initialize(address _initOwner) public initializer {
        __Ownable_init(_initOwner);
        __RoleAccess_init();

        // Default admin roles will control these two roles
        _setRoleAdmin(PARAMETER_SETTER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(PAUSER_ROLE, DEFAULT_ADMIN_ROLE);
    }

    // ********** VIEW FUNCTIONS ********** //
    function getPair(address _tokenA, address _tokenB) external view returns (address) {
        return pairs[_tokenA][_tokenB];
    }

    function getReserves(address _tokenA, address _tokenB) external view returns (uint256 reserveA, uint256 reserveB) {
        return Pair(pairs[_tokenA][_tokenB]).getReserves();
    }

    // ********** MAIN FUNCTIONS ********** //
    function createPair(address _tokenA, address _tokenB, uint256 _fee) external returns (address pair) {
        require(_fee <= 1000, "Factory: invalid fee");
        require(_tokenA != _tokenB, "Factory: identical tokens");

        (address token0, address token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
        require(pairs[token0][token1] == address(0), "Factory: pair exists");

        bytes memory bytecode = type(Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));

        assembly {
            pair := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            if iszero(extcodesize(pair)) {
                revert(0, 0)
            }
        }

        Pair(pair).initialize(token0, token1, _fee);
        pairs[token0][token1] = pair;
        pairs[token1][token0] = pair;

        emit PairCreated(token0, token1, pair);
    }

    function setFee(address _pair, uint256 _fee) external onlyRole(PARAMETER_SETTER_ROLE) {
        require(_fee <= 1000, "Pair: invalid fee");
        Pair(_pair).setFee(_fee);

        emit PairFeeChanged(_pair, _fee);
    }

    function lockPair(address _pair) external onlyRole(PAUSER_ROLE) {
        pairLocked[_pair] = true;
        emit PairLocked(_pair);
    }

    function unlockPair(address _pair) external onlyRole(PAUSER_ROLE) {
        pairLocked[_pair] = false;
        emit PairUnlocked(_pair);
    }
}
