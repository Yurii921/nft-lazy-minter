// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

// This is developed with OpenZeppelin contracts v4.8.0.
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";
// This is developed with Chainlink contracts v0.5.1.
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import "./interfaces/IVRFCoordinatorV2.sol";
import "./interfaces/IERC721LazyMinterLimitedSupply.sol";

contract ChainlinkRandomGenerator is Context, AccessControl, VRFConsumerBaseV2 {
    // _______________ Structs _______________

    struct Request {
        bool fulfilled;
        address requestor;
    }

    // _______________ Constants _______________

    bytes32 public constant RANDOM_REQUESTOR = keccak256("RANDOM_REQUESTOR");

    uint16 public constant REQUEST_CONFIRMATIONS = 3;

    // _______________ Storage _______________

    IVRFCoordinatorV2 public immutable vrfCoordinator;

    uint32 public immutable maxNumWords;

    bytes32 public immutable keyHash;

    /**
     * @notice For pre-pay of use of Chainlink VRF requests, a subscription can be created and funded with
     * the subscription manager at https://vrf.chain.link/.
     *
     * See the example of creation of a new subscription on the Goerli testnet
     * https://docs.chain.link/vrf/v2/subscription/examples/get-a-random-number/#create-and-fund-a-subscription.
     */
    uint64 public immutable subscriptionId;

    // An ID of a request => its status.
    mapping(uint256 => Request) public requests;

    uint32 public callbackGasLimitMultiplier;

    IERC721LazyMinterLimitedSupply public nft;

    // _______________ Errors _______________

    error MaxNumWordsExceeded(uint256 _maxNumWords, uint32 _tooManyWords);

    // // error UnknownRequestId(uint256 _id);

    // _______________ Events _______________

    event CallbackGasLimitMultiplierSet(uint32 _multiplier);

    event NFTAddressSet(address _nft);

    event NumbersRequested(uint256 indexed _requestId, uint32 _wordNumber, address _requestor);

    event NumbersReceived(uint256 indexed _requestId);

    // _______________ Constructor _______________

    /**
     * @notice Values of `_vrfCoordinator` and `_keyHash` depend on a used network,
     * see https://docs.chain.link/docs/vrf-contracts/#configurations to get them.
     */
    constructor(
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint64 _subscriptionId,
        address _nft
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        vrfCoordinator = IVRFCoordinatorV2(_vrfCoordinator);
        maxNumWords = vrfCoordinator.MAX_NUM_WORDS();

        keyHash = _keyHash;
        subscriptionId = _subscriptionId;

        uint32 multiplier = 40_000;
        callbackGasLimitMultiplier = multiplier;
        emit CallbackGasLimitMultiplierSet(multiplier);

        nft = IERC721LazyMinterLimitedSupply(_nft);
        emit NFTAddressSet(_nft);

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    // _______________ External functions _______________

    // The functions are arranged in call order according to the basic use of this contract.

    function setCallbackGasLimitMultiplier(uint32 _multiplier) external onlyRole(DEFAULT_ADMIN_ROLE) {
        assert(_multiplier != 0);

        callbackGasLimitMultiplier = _multiplier;
        emit CallbackGasLimitMultiplierSet(_multiplier);
    }

    function setNFTAddress(address _nft) external onlyRole(DEFAULT_ADMIN_ROLE) {
        assert(_nft != address(0));

        nft = IERC721LazyMinterLimitedSupply(_nft);
        emit NFTAddressSet(_nft);
    }

    // prettier-ignore
    function requestNumbers(uint32 _wordNumber) external onlyRole(RANDOM_REQUESTOR) returns (uint256 requestId) {
        if (_wordNumber > maxNumWords)
            revert MaxNumWordsExceeded(maxNumWords, _wordNumber);

        // Reverts if `subscriptionId` is uncorrect or not funded.
        requestId = vrfCoordinator.requestRandomWords(
            keyHash,
            subscriptionId,
            REQUEST_CONFIRMATIONS,
            _wordNumber * callbackGasLimitMultiplier, // A callback gas limit for the Chainlink VRF.
            _wordNumber
        );

        requests[requestId] = Request({ fulfilled: false, requestor: _msgSender() });
        emit NumbersRequested(requestId, _wordNumber, _msgSender());

        return requestId;
    }

    // _______________ Internal functions _______________

    // See `VRFConsumerBaseV2.sol` for details.
    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        // // Request storage request = requests[_requestId];
        // // if (request.requestor == address(0))
        // //     revert UnknownRequestId(_requestId);

        // // request.fulfilled = true;
        requests[_requestId].fulfilled = true;
        emit NumbersReceived(_requestId);

        nft.mintNFTs(_requestId, _randomWords);
    }
}
