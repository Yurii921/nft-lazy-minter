# Solidity API

## ERC721LazyMinterLimitedSupply

### Request

```solidity
struct Request {
  bool minted;
  uint256 fromNFTId;
  uint32 nftNumber;
  address recipient;
}
```

### uris

```solidity
mapping(uint256 => string) uris
```

### lastNFTId

```solidity
uint256 lastNFTId
```

### randomGenerator

```solidity
contract IRandomGenerator randomGenerator
```

### requests

```solidity
mapping(uint256 => struct ERC721LazyMinterLimitedSupply.Request) requests
```

### nextNFTId

```solidity
uint256 nextNFTId
```

### MaxNumNFTsExceeded

```solidity
error MaxNumNFTsExceeded(uint256 _lastNFTId, uint256 _toNFTId)
```

### EmptyURIArray

```solidity
error EmptyURIArray()
```

### URISettingNotCompleted

```solidity
error URISettingNotCompleted()
```

### OnlyRandomGenerator

```solidity
error OnlyRandomGenerator()
```

### NFTNumberSet

```solidity
event NFTNumberSet(uint256 _nftNumber)
```

### URISet

```solidity
event URISet(uint256 _nftId, string _uri)
```

### URISettingCompleted

```solidity
event URISettingCompleted()
```

### RandomGeneratorSet

```solidity
event RandomGeneratorSet(address _randomGenerator)
```

### NFTsRequested

```solidity
event NFTsRequested(address _recipient, uint256 _nftNumber, uint256 _fromNFTId)
```

### onlyRandomGenerator

```solidity
modifier onlyRandomGenerator()
```

### constructor

```solidity
constructor(string _name, string _symbol) public
```

### setNFTNumber

```solidity
function setNFTNumber(uint256 _nftNumber) external
```

### setURIs

```solidity
function setURIs(string[] _uris) external
```

### setRandomGenerator

```solidity
function setRandomGenerator(address _randomGenerator) external
```

### requestNFTs

```solidity
function requestNFTs(uint32 _nftNumber) external
```

### mintNFTs

```solidity
function mintNFTs(uint256 _requestId, uint256[] _randomNumbers) external
```

### tokenURI

```solidity
function tokenURI(uint256 _nftId) public view virtual returns (string)
```

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool)
```

_See the function `supportsInterface` in `IERC165` for details._

