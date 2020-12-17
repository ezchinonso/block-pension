var PensionScheme = artifacts.require("./PensionScheme.sol");

module.exports = function(deployer) {
  deployer.deploy(PensionScheme);
};
