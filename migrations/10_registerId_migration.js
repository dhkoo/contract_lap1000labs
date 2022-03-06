const RegisterId = artifacts.require("RegisterId");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(RegisterId);
};
