# Solidity API

## ChainlinkRandomGenerator

### Request

```solidity
struct Request {
  bool fulfilled;
  address requestor;
}
```

### RANDOM_REQUESTOR

```solidity
bytes32 RANDOM_REQUESTOR
```

### REQUEST_CONFIRMATIONS

```solidity
uint16 REQUEST_CONFIRMATIONS
```

### vrfCoordinator

```solidity
contract IVRFCoordinatorV2 vrfCoordinator
```

### maxNumWords

```solidity
uint32 maxNumWords
```

### keyHash

```solidity
bytes32 keyHash
```

### subscriptionId

```solidity
uint64 subscriptionId
```

For pre-pay of use of Chainlink VRF requests, a subscription can be created and funded with
the subscription manager at https://vrf.chain.link/.

See the example of creation of a new subscription on the Goerli testnet
https://docs.chain.link/vrf/v2/subscription/examples/get-a-random-number/#create-and-fund-a-subscription.

### requests

```solidity
mapping(uint256 => struct ChainlinkRandomGenerator.Request) requests
```

### callbackGasLimitMultiplier

```solidity
uint32 callbackGasLimitMultiplier
```

### nft

```solidity
contract IERC721LazyMinterLimitedSupply nft
```

### MaxNumWordsExceeded

```solidity
error MaxNumWordsExceeded(uint256 _maxNumWords, uint32 _tooManyWords)
```

### CallbackGasLimitMultiplierSet

```solidity
event CallbackGasLimitMultiplierSet(uint32 _multiplier)
```

### NFTAddressSet

```solidity
event NFTAddressSet(address _nft)
```

### NumbersRequested

```solidity
event NumbersRequested(uint256 _requestId, uint32 _wordNumber, address _requestor)
```

### NumbersReceived

```solidity
event NumbersReceived(uint256 _requestId)
```

### constructor

```solidity
constructor(address _vrfCoordinator, bytes32 _keyHash, uint64 _subscriptionId, address _nft) public
```

Values of `_vrfCoordinator` and `_keyHash` depend on a used network,
see https://docs.chain.link/docs/vrf-contracts/#configurations to get them.

### setCallbackGasLimitMultiplier

```solidity
function setCallbackGasLimitMultiplier(uint32 _multiplier) external
```

### setNFTAddress

```solidity
function setNFTAddress(address _nft) external
```

### requestNumbers

```solidity
function requestNumbers(uint32 _wordNumber) external returns (uint256 requestId)
```

### fulfillRandomWords

```solidity
function fulfillRandomWords(uint256 _requestId, uint256[] _randomWords) internal
```

