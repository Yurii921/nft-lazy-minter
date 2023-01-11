// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC721LazyMinterLimitedSupply {
    function mintNFTs(uint256 _requestId, uint256[] memory _randomNumbers) external;
}
