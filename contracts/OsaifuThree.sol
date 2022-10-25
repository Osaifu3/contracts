// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0 <0.9.0;

import "./modules/Permission.sol";
import "./modules/Signature.sol";
import "./modules/DiamondCutModule.sol";

contract OsaifuThree is Permission, Signature, DiamondCutModule {
    uint256 constant currentVersion = 1;
    uint256 version = 0;

    function Initialize() public {
        require(version < currentVersion, "Already initialized");
        __Ownable_init();
        __EIP712_init("OsaifuThree", "1");
        version = currentVersion;
    }

    function call(address target, bytes calldata payload) public {
        require(
            delegatee[target].isAuthorized(msg.sender, target, payload),
            "Permission: not authorized"
        );
        (bool success, bytes memory returnData) = target.call(payload);
        require(success, string(returnData));
    }

    function callFromOwner(address target, bytes calldata payload)
        public
        onlyOwner
    {
        (bool success, bytes memory returnData) = target.call(payload);
        require(success, string(returnData));
    }

    receive() external payable {}
}
