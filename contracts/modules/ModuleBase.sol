// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0 <0.9.0;

import "../interface/osaifu/IACL.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract ModuleBase is OwnableUpgradeable {
    mapping (address => uint256) public nonces;
}