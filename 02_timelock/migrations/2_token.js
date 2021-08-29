const Mocktoken1 = artifacts.require("Mocktoken1")
const Mocktoken2 = artifacts.require("Mocktoken2");

module.exports = function (deployer, _network, accounts) {
  deployer.deploy(Mocktoken1, {from: accounts[6]});
  deployer.deploy(Mocktoken2, {from: accounts[7]});
};
