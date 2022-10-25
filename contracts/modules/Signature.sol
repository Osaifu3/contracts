// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0 <0.9.0;

import "../interface/eips/IEIP1271.sol";
import "./Permission.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Signature is IEIP1271, Permission {
    using ECDSA for bytes32;
    // bytes4(keccak256("isValidSignature(bytes32,bytes)")
    bytes4 constant internal MAGICVALUE = 0x1626ba7e;

    function isValidSignature(bytes32 _hash, bytes memory _signature)
        public view override 
        returns (bytes4 magicValue) {
            // First we recover the signature

        }
}