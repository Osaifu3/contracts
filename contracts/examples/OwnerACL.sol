// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0 <0.9.0;
import "../interface/osaifu/IACL.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// @dev This contract is an example of ACL implementation.
//      It allows only the owner to call any function.
contract OwnerACL is IACL, Ownable {
    function isAuthorized(address caller, address, bytes calldata) public view returns (bool) {
        return caller == owner();
    }
    function isSignAllowed(address caller, address) public view returns (bool) {
        return caller == owner();
    }
}