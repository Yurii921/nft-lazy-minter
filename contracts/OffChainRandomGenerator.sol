// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

// This is developed with OpenZeppelin contracts v4.8.0.
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "./interfaces/IERC721LazyMinterLimitedSupply.sol";

/// @title Off-chain random number generator.
contract OffChainRandomGenerator is Context, AccessControl {
    // _______________ Structs _______________

    struct Request {
        bool fulfilled;
        uint32 numberOfNumbers;
        address requestor;
    }

    // _______________ Constants _______________

    bytes32 public constant RANDOM_REQUESTOR = keccak256("RANDOM_REQUESTOR");

    bytes32 public constant RANDOM_PROVIDER = keccak256("RANDOM_PROVIDER");

    // _______________ Storage _______________

    // An ID of a request => its status.
    mapping(uint256 => Request) public requests;

    IERC721LazyMinterLimitedSupply public nft;

    // ____ Generation of IDs for `requests` ____

    uint256 public nextRequestId;

    // _______________ Errors _______________

    error NotEnoughNumbers(uint256 _id, uint32 _numbersNeeded, uint256 _numbersReceived);

    // _______________ Events _______________

    event NFTAddressSet(address _nft);

    event NumbersRequested(uint256 indexed _requestId, uint32 _wordNumber, address _requestor);

    event NumbersReceived(uint256 indexed _requestId);

    // _______________ Constructor _______________

    constructor(address _nft) {
        nft = IERC721LazyMinterLimitedSupply(_nft);
        emit NFTAddressSet(_nft);

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    // _______________ External functions _______________

    // The functions are arranged in call order according to the basic use of this contract.

    function setNFTAddress(address _nft) external onlyRole(DEFAULT_ADMIN_ROLE) {
        assert(_nft != address(0));

        nft = IERC721LazyMinterLimitedSupply(_nft);
        emit NFTAddressSet(_nft);
    }

    // prettier-ignore
    function requestNumbers(uint32 _numberOfNumbers) external onlyRole(RANDOM_REQUESTOR) returns (uint256 requestId) {
        requestId = nextRequestId++; // Warning. `nextRequestId` is incremented in this instruction.

        requests[requestId] = Request({
            fulfilled: false,
            numberOfNumbers: _numberOfNumbers,
            requestor: _msgSender()
        });
        emit NumbersRequested(requestId, _numberOfNumbers, _msgSender());

        return requestId;
    }

    // prettier-ignore
    function fulfillRequest(uint256 _requestId, uint256[] memory _randomNumbers) external onlyRole(RANDOM_PROVIDER) {
        Request storage request = requests[_requestId];
        if (uint256(request.numberOfNumbers) != _randomNumbers.length)
            revert NotEnoughNumbers(_requestId, request.numberOfNumbers, _randomNumbers.length);

        request.fulfilled = true;
        emit NumbersReceived(_requestId);

        nft.mintNFTs(_requestId, _randomNumbers);
    }
}
