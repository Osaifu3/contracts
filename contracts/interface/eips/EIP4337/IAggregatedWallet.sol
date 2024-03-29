// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0 <0.9.0;

import "./IWallet.sol";

interface IAggregatedWallet is IWallet {
    function getAggregator() external view returns (address);
}
