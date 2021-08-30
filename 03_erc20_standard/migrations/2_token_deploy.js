const Token = artifacts.require("Token");

module.exports = function (deployer, _network, accounts) {
  deployer.deploy(Token, 'my tok', 'TOK', 18, 1000, {from:accounts[0]});
};
/*
not needed for truffle tests
needed for ganache or other tests maybe , not sure
*/