// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0 <0.9.0;

interface IACL {
    function isAuthorized(address caller, address target, bytes calldata payload) external view returns (bool);
    function isSignAllowed(address caller, address target) external view returns (bool);
}