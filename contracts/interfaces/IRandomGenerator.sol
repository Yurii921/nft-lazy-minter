// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IRandomGenerator {
    function requestNumbers(uint32 _wordNumber) external returns (uint256 requestId);
}
