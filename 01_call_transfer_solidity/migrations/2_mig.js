const EtherSender = artifacts.require("EtherSender");
const EtherReceiver = artifacts.require("EtherReceiver");

module.exports = function (deployer, _network, _accounts) {
  // automatic supplied by truffle
    deployer.deploy(EtherSender);
    deployer.deploy(EtherReceiver);
    
};
