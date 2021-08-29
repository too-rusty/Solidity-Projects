const Timelock = artifacts.require("Timelock");

module.exports = function (deployer, _network, _accounts) {
  // automatic supplied by truffle
  deployer.deploy(Timelock);
};
