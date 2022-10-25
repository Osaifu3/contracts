// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0 <0.9.0;

import "./ModuleBase.sol";
import "../interface/osaifu/IRecoveryVerifier.sol";

contract SocialRecovery is ModuleBase {
    address public recoveryVerifier = address(0);

    event RecoveryVerifierChanged(address indexed oldRecoveryVerifier, address indexed newRecoveryVerifier);

    function setRecoveryVerifier(address _recoveryVerifier) external onlyOwner {
        recoveryVerifier = _recoveryVerifier;
        emit RecoveryVerifierChanged(recoveryVerifier, _recoveryVerifier);
    }

    function recover(address newOwner, bytes calldata recoverProof) external {
        require(recoveryVerifier != address(0), "SocialRecovery: recovery verifier not set");
        require(IRecoveryVerifier(recoveryVerifier).verifyRecover(newOwner, recoverProof), "SocialRecovery: invalid recover proof");
        _transferOwnership(newOwner);
    }
}