// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

// This is developed with Chainlink contracts v0.5.1.
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

interface IVRFCoordinatorV2 is VRFCoordinatorV2Interface {
    function MAX_NUM_WORDS() external view returns (uint32);
}
