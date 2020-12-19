var PensionScheme = artifacts.require("./PensionScheme.sol");
var Factory = artifacts.require("./PFAFactory.sol");

module.exports = async function(deployer) {
  await deployer.deploy(Factory);
  factory = await Factory.deployed()

  await deployer.deploy(PensionScheme, factory.address);
};
