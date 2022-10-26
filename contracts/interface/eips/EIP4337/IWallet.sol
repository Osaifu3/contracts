// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0 <0.9.0;

import "./IUserOperation.sol";

interface IWallet {
    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 requestId,
        address aggregator,
        uint256 missingWalletFunds
    ) external;
}
