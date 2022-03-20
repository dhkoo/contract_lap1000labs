const NameBook = artifacts.require("NameBook");

module.exports = async function (deployer, network, accounts) {
  if (network == "cypress") {
    await deployer.deploy(NameBook);
  }
};
