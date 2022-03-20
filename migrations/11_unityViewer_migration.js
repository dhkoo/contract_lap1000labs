const ConfigYaml = require("config-yaml");
const lapConfig = ConfigYaml("../lap_config/contracts.yaml");
const UnityViewer = artifacts.require("UnityViewer");

module.exports = async function (deployer, network, accounts) {
  if (network == "cypress") {
    const alapAddr = lapConfig[network].alap;
    const donationAddr = lapConfig[network].Donation;
    const nameBookAddr = lapConfig[network].NameBook;
    const alapRegistrationAddr = lapConfig[network].AlapRegistration;
    const commentBoxAddr = lapConfig[network].CommentBox;
    await deployer.deploy(
      UnityViewer,
      alapAddr,
      donationAddr,
      nameBookAddr,
      alapRegistrationAddr,
      commentBoxAddr
    );
  }
};
