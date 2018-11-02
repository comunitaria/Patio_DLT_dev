var SimpleEscrow = artifacts.require("./SimpleEscrow.sol");
var Voting = artifacts.require("./Voting.sol")

module.exports = function(deployer) {
  //deployer.deploy(SimpleEscrow, '0xb0d5fa336f575d9a9f49a454a7e6b71874c4e15f', '0xf17f52151ebef6c7334fad080c5704d77216b732');
  deployer.deploy(Voting);
};
