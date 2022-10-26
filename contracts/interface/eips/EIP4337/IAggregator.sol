// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0 <0.9.0;

import "./IUserOperation.sol";

interface IAggregator {
    function validateUserOpSignature(
        UserOperation calldata userOp,
        bool offChainSigCheck
    )
        external
        view
        returns (
            bytes memory sigForUserOp,
            bytes memory sigForAggregation,
            bytes memory offChainSigInfo
        );

    function aggregateSignatures(bytes[] calldata sigsForAggregation)
        external
        view
        returns (bytes memory aggregatesSignature);

    function validateSignatures(
        UserOperation[] calldata userOps,
        bytes calldata signature
    ) external view;
}
