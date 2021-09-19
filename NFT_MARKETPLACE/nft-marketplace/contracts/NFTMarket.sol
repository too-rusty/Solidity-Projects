// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract NFTMarket is ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds; // for the items created
    Counters.Counter private _itemsSold; // for the items sold


    // like pay for listing
    uint256 private _listingPrice = 0.025 ether;

    constructor() Ownable() {}

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        // nftContract , tokenId pair would point to the exact contract
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated (
        uint indexed itemId,
        address indexed nftContract,
        uint indexed tokenId,
        address seller,
        address owner,
        uint price,
        bool sold
    );

    event MarketItemSold (
        
    );

    function getListingPrice() public view returns (uint256) { return _listingPrice; }
    function setListingPrice(uint _price) public onlyOwner {
        _listingPrice = _price;
    }

    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, 'price cannot be zero');
        require(msg.value >= getListingPrice(), 'price must be listing price');

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem (
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        // do we need this , this should happen when someone buys
        emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, address(0), price, false);
    }

    function createMarketSale(
        address nftContract,
        uint256 itemId
    ) public payable nonReentrant {
        // when someone buys then actually do this sale
        // transfer money to the buyer
        uint price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;
        require(msg.value >= price, 'price not fulfilled');

        idToMarketItem[itemId].seller.transfer(msg.value); // pay the money to seller / owner
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        // transfer item in the context of the contract

        idToMarketItem[itemId].owner = payable(msg.sender);
        _itemsSold.increment();
        payable(owner()).transfer(getListingPrice()); // pay the commission to the owner
        // this should happen at the time of listing imo
    }

    // function to list all the unsold item, purchased items by me and created items by me

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        // fetch unsold items
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = itemCount - _itemsSold.current();

        uint currentIdx = 0;
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);

        for(uint i = 0; i < itemCount; i++) {
            if(idToMarketItem[i+1].owner == address(0)) {
                // this is not yet sold
                uint currentId = idToMarketItem[i+1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIdx] = currentItem;
                currentIdx += 1;
            }
        }
        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory){
        // all nfts that are created by me or owner by me , i.e those that are mine
        uint itemCount = 0;
        uint totalItemCount = _itemIds.current();
        for(uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i+1].owner == msg.sender) {
                itemCount+=1;
            }
        }
        MarketItem[] memory items = new MarketItem[](itemCount);
        uint currentIdx = 0;
        for(uint i = 0; i < itemCount; i++) {
            if(idToMarketItem[i+1].owner == _msgSender()) {
                // this is not yet sold
                uint currentId = idToMarketItem[i+1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIdx] = currentItem;
                currentIdx += 1;
            }
        }
        return items;
    }

    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        // items created by me , i am the seller
        uint itemCount = 0;
        uint totalItemCount = _itemIds.current();
        for(uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i+1].seller == _msgSender()) {
                itemCount+=1;
            }
        }
        MarketItem[] memory items = new MarketItem[](itemCount);
        uint currentIdx = 0;
        for(uint i = 0; i < itemCount; i++) {
            if(idToMarketItem[i+1].seller == _msgSender()) {
                // this is not yet sold
                uint currentId = idToMarketItem[i+1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIdx] = currentItem;
                currentIdx += 1;
            }
        }
        return items;
    }



}

