const AlapRegistration = artifacts.require("AlapRegistration");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(AlapRegistration);
};
