// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0 <0.9.0;

interface IEIP1271 {
    function isValidSignature(bytes32 _hash, bytes memory _signature)
        external
        returns (bytes4 magicValue);
}
