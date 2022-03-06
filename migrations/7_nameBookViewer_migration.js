const ConfigYaml = require("config-yaml");
const addrBook = ConfigYaml("../addrBook.yaml");
const NameBookViewer = artifacts.require("NameBookViewer");

module.exports = async function (deployer, network, accounts) {
  if (network == "cypress") {
    await deployer.deploy(NameBookViewer, addrBook[network].ProxyNameBook);
  }
};
