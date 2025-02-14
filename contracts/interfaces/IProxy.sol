// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

interface IProxy {
    function admin() external view returns (address);
    function implementation() external view returns (address);

    function changeAdmin(address newAdmin) external;
    function upgradeTo(address newImplementation) external;
}
