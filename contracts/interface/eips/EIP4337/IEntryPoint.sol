// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0 <0.9.0;

import "./IUserOperation.sol";
import "./IAggregator.sol";

interface IEntryPoint {
    function handleOps(
        UserOperation[] calldata ops,
        address payable beneficiary
    ) external;

    function handleAggregatedOps(
        UserOpsPerAggregator[] calldata opsPerAggregator,
        address payable beneficiary
    ) external;

    function simulateValidation(
        UserOperation calldata userOp,
        bool offChainSigCheck
    )
        external
        returns (
            uint256 preOpGas,
            uint256 prefund,
            address actualAggregator,
            bytes memory sigForUserOp,
            bytes memory sigForAggregation,
            bytes memory offChainSigInfo
        );

    struct UserOpsPerAggregator {
        UserOperation[] userOps;
        IAggregator aggregator;
        bytes signature;
    }
}
