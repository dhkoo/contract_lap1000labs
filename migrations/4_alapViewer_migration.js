const AlapViewer = artifacts.require("AlapViewer");
const alapAddr = "0x22d28b7e69eb45fdeaaf7b57161a53d94c648caf";

module.exports = async function(deployer, network, accounts) {
  await deployer.deploy(AlapViewer, alapAddr);
};
