// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0 <0.9.0;

import "../interface/osaifu/IACL.sol";
import "./ModuleBase.sol";

contract Permission is ModuleBase {
    address public custodian;
    mapping(address => IACL) public delegatee;

    // Events.
    event SetDelegatee(address indexed delegatee, address indexed acl);
    event SetCustodian(address indexed custodian);

    // Modifiers.
    modifier onlyCustodian() {
        require(msg.sender == custodian, "Permission: only custodian");
        _;
    }

    modifier transactionCheck(address target, bytes calldata payload) {
        require(
            delegatee[target].isAuthorized(msg.sender, target, payload),
            "Permission: not authorized"
        );
        _;
    }

    modifier signatureCheck(address target) {
        require(
            delegatee[target].isSignAllowed(msg.sender, target),
            "Permission: not allowed"
        );
        _;
    }

    // Functions.
    function _setCustodian(address _custodian) internal {
        emit SetCustodian(_custodian);
        custodian = _custodian;
    }

    function _setDelegatee(address _delegatee, IACL _acl) internal {
        emit SetDelegatee(_delegatee, address(_acl));
        delegatee[_delegatee] = _acl;
    }

    function setDelegatee(address _delegatee, IACL _acl)
        external
        onlyCustodian
    {
        _setDelegatee(_delegatee, _acl);
    }

    function delDelegatee(address _delegatee) external onlyOwner {
        _setDelegatee(_delegatee, IACL(address(0)));
    }

    function setCustodian(address _custodian) external onlyOwner {
        _setCustodian(_custodian);
    }
}
