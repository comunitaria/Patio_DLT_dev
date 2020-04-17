var ProviderRating = artifacts.require("./ProviderRating.sol");
var ListAbiertaVotingResult = artifacts.require("./ListAbiertaVotingResult.sol");


module.exports = function(deployer) {
  deployer.deploy(ProviderRating);
  deployer.deploy(ListAbiertaVotingResult);
};
