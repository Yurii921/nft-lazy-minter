# Solidity API

## OffChainRandomGenerator

### Request

```solidity
struct Request {
  bool fulfilled;
  uint32 numberOfNumbers;
  address requestor;
}
```

### RANDOM_REQUESTOR

```solidity
bytes32 RANDOM_REQUESTOR
```

### RANDOM_PROVIDER

```solidity
bytes32 RANDOM_PROVIDER
```

### requests

```solidity
mapping(uint256 => struct OffChainRandomGenerator.Request) requests
```

### nft

```solidity
contract IERC721LazyMinterLimitedSupply nft
```

### nextRequestId

```solidity
uint256 nextRequestId
```

### NotEnoughNumbers

```solidity
error NotEnoughNumbers(uint256 _id, uint32 _numbersNeeded, uint256 _numbersReceived)
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
constructor(address _nft) public
```

### setNFTAddress

```solidity
function setNFTAddress(address _nft) external
```

### requestNumbers

```solidity
function requestNumbers(uint32 _numberOfNumbers) external returns (uint256 requestId)
```

### fulfillRequest

```solidity
function fulfillRequest(uint256 _requestId, uint256[] _randomNumbers) external
```

