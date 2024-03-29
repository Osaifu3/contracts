// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "./modules/Permission.sol";
import "./modules/Signature.sol";
import "./modules/DiamondCutModule.sol";
import "./modules/SocialRecovery.sol";

contract OsaifuThree is Permission, Signature, SocialRecovery, DiamondCutModule {
    address public constant Ether = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function Initialize(address owner, address custodian) public initializer {
        _transferOwnership(owner);
        _setCustodian(custodian);
        __EIP712_init("OsaifuThree", "1");
    }

    function call(address target, bytes calldata payload) public {
        require(
            delegatee[target].isAuthorized(msg.sender, target, payload),
            "Permission: not authorized"
        );
        (bool success, bytes memory returnData) = target.call(payload);
        require(success, string(returnData));
    }

    function callWithEther(
        address target,
        uint256 amount,
        bytes calldata payload
    ) public payable {
        require(
            delegatee[target].isAuthorized(msg.sender, target, payload),
            "Permission: not authorized"
        );

        require(
            delegatee[target].isAuthorized(
                msg.sender,
                Ether,
                abi.encode(amount, target)
            ),
            "Permission: ether not allowed"
        );

        (bool success, bytes memory returnData) = target.call{value: amount}(
            payload
        );
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
