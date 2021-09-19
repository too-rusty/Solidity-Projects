const { expect } = require("chai");
const { ethers } = require("hardhat");

// describe("Greeter", function () {
//   it("Should return the new greeting once it's changed", async function () {
//     const Greeter = await ethers.getContractFactory("Greeter");
//     const greeter = await Greeter.deploy("Hello, world!");
//     await greeter.deployed();

//     expect(await greeter.greet()).to.equal("Hello, world!");

//     const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

//     // wait until the transaction is mined
//     await setGreetingTx.wait();

//     expect(await greeter.greet()).to.equal("Hola, mundo!");
//   });
// });

describe("NFTMarket", function() {
  it('Should create and execute market sales', async function () {
    const Market = await ethers.getContractFactory("NFTMarket")
    const market = await Market.deploy()
    await market.deployed()
    const marketAddress = market.address

    const NFT = await ethers.getContractFactory("NFT")
    const nft = await NFT.deploy(marketAddress)
    await nft.deployed()
    const nftContractAddress = nft.address

    let listingPrice = await market.getListingPrice()
    listingPrice = listingPrice.toString()

    const auctionPrice = ethers.utils.parseUnits('100', 'ether')

    await nft.createToken('sometoken1')
    await nft.createToken('sometoken2')

    await market.createMarketItem(nftContractAddress, 1, auctionPrice, { value : listingPrice })
    await market.createMarketItem(nftContractAddress, 2, auctionPrice, { value : listingPrice })

    const X = await ethers.getSigners()
    console.log('X: ', X[1].address)
    const [_, buyerAddress] = X

    await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, {value : auctionPrice})
    console.log('buyer address: ', buyerAddress.address)
    let items = await market.fetchMarketItems()
    items = await Promise.all(items.map(async i => {
      const tokenUri = await nft.tokenURI(i.tokenId)
      let item = {
        price: i.price.toString(),
        tokenId: i.tokenId.toString(),
        seller: i.seller,
        owner: i.owner,
        tokenUri
      }
      return item
    }))

    console.log('items: ', items)
    console.log('owner of tokenid 1: ', await nft.ownerOf(1))

  });
});