var ProviderRating = artifacts.require("./ProviderRating.sol");

module.exports = function(deployer) {
  deployer.deploy(ProviderRating);
};
