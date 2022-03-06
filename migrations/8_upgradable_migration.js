const ProxyNameBook = artifacts.require("ProxyNameBook");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(ProxyNameBook);
};
