// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0 <0.9.0;

import "./ModuleBase.sol";
import "../interface/eips/EIP2535/IDiamondCut.sol";
import "../interface/eips/EIP2535/IDiamondLoupe.sol";

import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract DiamondCutModule is
    ModuleBase,
    IDiamondCut,
    IDiamondLoupe,
    EIP712Upgradeable
{
    using SignatureChecker for address;

    // Variables for _facets.
    uint256 public facetCount;
    Facet[] private _facets;
    mapping(bytes4 => address) public facetAddress;
    mapping(address => uint256) public facetIndex;

    function _addFacet(address _facet, bytes4[] memory _selectors) internal {
        // Check if the facet is already added.
        if (facetIndex[_facet] == 0) {
            // Add the facet.
            facetCount++;
            facetIndex[_facet] = facetCount;
            _facets.push(Facet(_facet, _selectors));
        } else {
            // Update the facet.
            uint256 index = facetIndex[_facet] - 1;
            _facets[index].functionSelectors = _selectors;
        }

        // Update the selectors.
        for (uint256 i = 0; i < _selectors.length; i++) {
            facetAddress[_selectors[i]] = _facet;
        }
    }

    function _removeFacet(address _facet) internal {
        // Check if the facet is already added.
        if (facetIndex[_facet] == 0) {
            return;
        }

        // Remove the facet.
        uint256 index = facetIndex[_facet] - 1;
        uint256 lastIndex = facetCount - 1;
        if (index != lastIndex) {
            _facets[index] = _facets[lastIndex];
            facetIndex[_facets[index].facetAddress] = index + 1;
        }
        _facets.pop();
        facetCount--;

        // Remove the selectors.
        for (uint256 i = 0; i < _facets[index].functionSelectors.length; i++) {
            delete facetAddress[_facets[index].functionSelectors[i]];
        }
    }

    function _replaceFacet(address _newFacet, bytes4[] memory _selectors)
        internal
    {
        // Check if the facet is already added.
        if (facetIndex[_newFacet] == 0) {
            return;
        }
        address _oldFacet = facetAddress[_selectors[0]];
        if (_oldFacet == address(0)) {
            return;
        }

        // Remove the facet.
        uint256 index = facetIndex[_oldFacet] - 1;
        uint256 lastIndex = facetCount - 1;
        if (index != lastIndex) {
            _facets[index] = _facets[lastIndex];
            facetIndex[_facets[index].facetAddress] = index + 1;
        }
        _facets.pop();
        facetCount--;

        // Remove the selectors.
        for (uint256 i = 0; i < _facets[index].functionSelectors.length; i++) {
            delete facetAddress[_facets[index].functionSelectors[i]];
        }

        // Add the facet.
        facetCount++;
        facetIndex[_newFacet] = facetCount;
        _facets.push(Facet(_newFacet, _selectors));

        // Update the selectors.
        for (uint256 i = 0; i < _selectors.length; i++) {
            facetAddress[_selectors[i]] = _newFacet;
        }
    }

    function _handleFacetCut(FacetCut[] memory _diamondCut) internal {
        for (uint256 i = 0; i < _diamondCut.length; i++) {
            FacetCut memory cut = _diamondCut[i];
            if (cut.action == FacetCutAction.Add) {
                _addFacet(cut.facetAddress, cut.functionSelectors);
            } else if (cut.action == FacetCutAction.Replace) {
                _replaceFacet(cut.facetAddress, cut.functionSelectors);
            } else if (cut.action == FacetCutAction.Remove) {
                _removeFacet(cut.facetAddress);
            } else {
                revert("DiamondCutModule: invalid action");
            }
        }
    }

    function facets() external view returns (Facet[] memory facets_) {
        facets_ = new Facet[](facetCount);
        for (uint256 i = 0; i < facetCount; i++) {
            facets_[i] = _facets[i];
        }
    }

    function facetFunctionSelectors(address _facet)
        external
        view
        returns (bytes4[] memory facetFunctionSelectors_)
    {
        uint256 index = facetIndex[_facet] - 1;
        return _facets[index].functionSelectors;
    }

    function facetAddresses()
        external
        view
        returns (address[] memory facetAddresses_)
    {
        facetAddresses_ = new address[](facetCount);
        for (uint256 i = 0; i < facetCount; i++) {
            facetAddresses_[i] = _facets[i].facetAddress;
        }
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external onlyOwner {
        _handleFacetCut(_diamondCut);
        if (_init != address(0)) {
            require(_calldata.length > 0, "DiamondCutModule: invalid calldata");
            (bool success, bytes memory returnData) = _init.delegatecall(
                _calldata
            );
            require(success, string(returnData));
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
    }

    function diamondCutWithSignature(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata,
        bytes calldata _signature
    ) public {
        bytes32 message = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    keccak256(
                        "DiamondCut(bytes32 cutHash,address init,bytes calldata,uint256 nonce)"
                    ),
                    keccak256(abi.encode(_diamondCut)),
                    _init,
                    keccak256(_calldata),
                    nonces[owner()]++
                )
            )
        );
        require(
            owner().isValidSignatureNow(message, _signature),
            "DiamondCutModule: invalid signature"
        );
        _handleFacetCut(_diamondCut);
        if (_init != address(0)) {
            require(_calldata.length > 0, "DiamondCutModule: invalid calldata");
            (bool success, bytes memory returnData) = _init.delegatecall(
                _calldata
            );
            require(success, string(returnData));
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
    }

    fallback() external payable {
        address facet = facetAddress[msg.sig];
        require(
            facet != address(0),
            "DiamondCutModule: invalid function selector"
        );
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
