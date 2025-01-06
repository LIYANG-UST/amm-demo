// SPDX-License-Identifier: MIT

pragma solidity >=0.8.20;

/**
 * @title RoleAccess
 *
 * @dev A role-based access control contract.
 */
contract RoleAccess {
    // ********** CONSTANTS ********** //
    bytes32 constant DEFAULT_ADMIN_ROLE = keccak256("DEFAULT_ADMIN_ROLE");

    // ********** STATE VARIABLES ********** //

    struct Role {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }
    mapping(bytes32 role => Role) public roles;

    // ********** EVENTS ********** //

    event RoleSet(address indexed account, bytes32 indexed role);
    event RoleRevoked(address indexed account, bytes32 indexed role);

    event AdminRoleTransferred(address indexed oldAdmin, address indexed newAdmin);

    // ********** MODIFIERS ********** //
    modifier onlyRole(bytes32 _role) {
        require(hasRole(msg.sender, _role), "RoleAccess: sender requires permission");
        _;
    }

    // ********** CONSTRUCTOR ********** //
    constructor() {
        _setRoleAdmin(DEFAULT_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);

        // The deployer has the default admin role
        _setRole(msg.sender, DEFAULT_ADMIN_ROLE);
    }

    // ********** VIEW FUNCTIONS ********** //
    function hasRole(address _account, bytes32 _role) public view returns (bool) {
        return roles[_role].hasRole[_account];
    }

    // ********** MAIN FUNCTIONS ********** //

    // Only those accounts with a role's admin role can set an account for that role
    function setRole(address _account, bytes32 _role) public onlyRole(roles[_role].adminRole) {
        _setRole(_account, _role);
    }

    function revokeRole(address _account, bytes32 _role) public onlyRole(roles[_role].adminRole) {
        _revokeRole(_account, _role);
    }

    function transferAdminRole(address _newAdmin) public onlyRole(roles[DEFAULT_ADMIN_ROLE].adminRole) {
        _setRole(_newAdmin, DEFAULT_ADMIN_ROLE);
        _revokeRole(msg.sender, DEFAULT_ADMIN_ROLE);
        emit AdminRoleTransferred(msg.sender, _newAdmin);
    }

    // ********** INTERNAL FUNCTIONS ********** //

    // Set a roles's admin role
    function _setRoleAdmin(bytes32 _role, bytes32 _adminRole) internal {
        roles[_role].adminRole = _adminRole;
    }

    // Grant a role to an account
    function _setRole(address _account, bytes32 _role) internal {
        roles[_role].hasRole[_account] = true;
        emit RoleSet(_account, _role);
    }

    function _revokeRole(address _account, bytes32 _role) internal {
        roles[_role].hasRole[_account] = false;
        emit RoleRevoked(_account, _role);
    }
}
