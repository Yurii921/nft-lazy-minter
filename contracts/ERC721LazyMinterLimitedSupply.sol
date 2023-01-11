// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

// This is developed with OpenZeppelin contracts v4.8.0.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "./interfaces/IERC721LazyMinterLimitedSupply.sol";
import "./interfaces/IRandomGenerator.sol";

contract ERC721LazyMinterLimitedSupply is IERC721LazyMinterLimitedSupply, Context, AccessControl, ERC721 {
    // _______________ Structs _______________

    struct Request {
        bool minted;
        uint256 fromNFTId;
        uint32 nftNumber;
        address recipient; // A recipient of NFTs.
    }

    // _______________ Storage _______________

    // An ID of an NFT => its URI.
    mapping(uint256 => string) public uris;

    uint256 public lastNFTId;

    IRandomGenerator public randomGenerator;

    // An ID of a request => its status.
    mapping(uint256 => Request) public requests;

    // ____ Generation of IDs for NFTs ____

    uint256 public nextNFTId;

    // _______________ Errors _______________

    error MaxNumNFTsExceeded(uint256 _lastNFTId, uint256 _toNFTId);

    error EmptyURIArray();

    error URISettingNotCompleted();

    error OnlyRandomGenerator();

    // _______________ Events _______________

    event NFTNumberSet(uint256 _nftNumber);

    event URISet(uint256 indexed _nftId, string _uri);

    event URISettingCompleted();

    event RandomGeneratorSet(address _randomGenerator);

    event NFTsRequested(address indexed _recipient, uint256 _nftNumber, uint256 _fromNFTId);

    // _______________ Modifiers _______________

    // prettier-ignore
    modifier onlyRandomGenerator() {
        if (_msgSender() != address(randomGenerator))
            revert OnlyRandomGenerator();
        _;
    }

    // _______________ Constructor _______________

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        assert(bytes(_name).length != 0 && bytes(_symbol).length != 0);

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    // _______________ External functions _______________

    // The functions are arranged in call order according to the basic use of this contract.

    function setNFTNumber(uint256 _nftNumber) external onlyRole(DEFAULT_ADMIN_ROLE) {
        assert(lastNFTId == 0 && _nftNumber != 0);

        lastNFTId = _nftNumber - 1;
        emit NFTNumberSet(_nftNumber);
    }

    // prettier-ignore
    function setURIs(string[] calldata _uris) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 fromNFTId = nextNFTId;
        uint256 toNFTId = fromNFTId + _uris.length - 1;

        if (lastNFTId < toNFTId)
            revert MaxNumNFTsExceeded(lastNFTId, toNFTId);
        if (_uris.length == 0)
            revert EmptyURIArray();

        // Setting of URIs.
        uint256 offset; // Offset NFT ID in the array `_uris`.
        for (uint256 nftId = fromNFTId; nftId <= toNFTId; ++nftId) {
            offset = nftId - fromNFTId;

            uris[nftId] = _uris[offset];
            emit URISet(nftId, _uris[offset]);
        }

        if (lastNFTId != toNFTId)
            nextNFTId = toNFTId;
        else { // A URI for the last NFT ID (`lastNFTId`) is set, i.e. URI setting is completed.
            nextNFTId = 0;
            emit URISettingCompleted();
        }
    }

    // prettier-ignore
    function setRandomGenerator(address _randomGenerator) external onlyRole(DEFAULT_ADMIN_ROLE) {
        // It is here to prevent minting before URI setting.
        if (bytes(uris[lastNFTId]).length == 0)
            revert URISettingNotCompleted();

        randomGenerator = IRandomGenerator(_randomGenerator);
        emit RandomGeneratorSet(_randomGenerator);
    }

    // prettier-ignore
    function requestNFTs(uint32 _nftNumber) external {
        uint256 fromNFTId = nextNFTId;
        nextNFTId += _nftNumber;

        uint256 requestId = randomGenerator.requestNumbers(_nftNumber);

        requests[requestId] = Request({
            minted: false,
            fromNFTId: fromNFTId,
            nftNumber: _nftNumber,
            recipient: _msgSender()
        });

        emit NFTsRequested(_msgSender(), _nftNumber, fromNFTId);
    }

    // prettier-ignore
    function mintNFTs(uint256 _requestId, uint256[] memory _randomNumbers) external onlyRandomGenerator {
        Request storage refRequest = requests[_requestId];
        refRequest.minted = true;

        uint256 size = _randomNumbers.length;
        uint256 fromNFTId = refRequest.fromNFTId;
        address recipient = refRequest.recipient;
        string memory tempURI;
        // // string storage refURI;
        for (uint256 i = 0; i < size; ++i) {
            // Minting.
            _safeMint(recipient, fromNFTId + i, "" /* data */);

            /*
             * Conversion of the obtained random numbers `_randomNumbers` to
             * random numbers in the range [`fromNFTId`, `lastNFTId`].
             *
             * Here `fromNFTId` is increased by `i` after each conversion, as this ID will already be occupied.
             */
            _randomNumbers[i] = (fromNFTId + i) + _randomNumbers[i] % (lastNFTId - (fromNFTId + i));

            // Swap of random URIs for the minted NFTs.
            tempURI = uris[_randomNumbers[i]];
            uris[_randomNumbers[i]] = uris[fromNFTId + i];
            uris[fromNFTId + i] = tempURI;
        }
    }

    // _______________ Public functions _______________

    function tokenURI(uint256 _nftId) public view virtual override returns (string memory) {
        _requireMinted(_nftId);

        return uris[_nftId];
    }

    /// @dev See the function `supportsInterface` in `IERC165` for details.
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
