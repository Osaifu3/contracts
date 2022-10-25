// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0 <0.9.0;
import "../interface/osaifu/IACL.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract ContractACL is IACL, EIP712, Ownable {
    using SignatureChecker for address;

    mapping (address => mapping (address => bool)) public allowedContracts;
    mapping (address => uint256) public nonce;

    event Authorize(address indexed caller, address indexed target);

    constructor() EIP712("ContractACL", "1") {}

    function authorize(address caller, address target, uint256 _nonce, bytes calldata signature) external onlyOwner {
        require(_nonce == nonce[target], "ContractACL: invalid nonce");
        bytes32 hash = _hashTypedDataV4(keccak256(abi.encode(
            keccak256("Authorize(address,address,uint256)"),
            caller,
            target,
            _nonce
        )));
        require(owner().isValidSignatureNow(hash, signature), "ContractACL: invalid signature");
        nonce[target]++;
        emit Authorize(caller, target);
        allowedContracts[target][caller] = true;
    }

    function approve(address caller, address target) public onlyOwner {
        emit Authorize(caller, target);
        allowedContracts[target][caller] = true;
    }

    function isAuthorized(address caller, address target, bytes calldata) external view returns (bool) {
        return allowedContracts[caller][target];
    }
    function isSignAllowed(address caller, address target) external view returns (bool) {
        return allowedContracts[caller][target];
    }
}