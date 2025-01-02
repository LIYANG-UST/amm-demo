// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

/**
 * @title RoleAccess
 *
 * @dev A role-based access control contract.
 */
contract RoleAccess {
    bytes32 constant DEFAULT_ADMIN_ROLE = keccak256("DEFAULT_ADMIN_ROLE");

    struct Role {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }
    mapping(bytes32 role => Role) public roles;

    modifier onlyRole(bytes32 _role) {
        require(hasRole(msg.sender, _role), "RoleAccess: sender requires permission");
        _;
    }

    constructor() {
        _setRoleAdmin(DEFAULT_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
    }


    function hasRole(address _account, bytes32 _role) public view returns (bool) {
        return roles[_role].hasRole[_account];
    }

    function setRole(address _account, bytes32 _role) public onlyRole(roles[_role].adminRole) {
        roles[_role].hasRole[_account] = true;
    }

    function _setRoleAdmin(bytes32 _role, bytes32 _adminRole) internal {
        roles[_role].adminRole = _adminRole;
    }
}
