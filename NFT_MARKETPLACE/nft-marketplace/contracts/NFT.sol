// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;

    constructor (address marketPlaceAddress)
    ERC721('Metaverse Tokens', 'METT')
    { contractAddress = marketPlaceAddress; }

    function createToken(string memory _tokenURI) public returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, _tokenURI); // provided by ERC721URIStorage
        setApprovalForAll(contractAddress, true);
        // [ _msgSender() ] [ operator ] = true
        // we are not calling a function in another contract but this is THE erc721 contract
        // which was inherited off course
        return newItemId;
    }


}