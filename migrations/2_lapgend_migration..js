const HallOfLapgend1 = artifacts.require("HallOfLapgend1");
const HallOfLapgend2 = artifacts.require("HallOfLapgend2");
const HallOfLapgend3 = artifacts.require("HallOfLapgend3");
const HallOfLapgend4 = artifacts.require("HallOfLapgend4");

module.exports = async function(deployer, network, accounts) {
  await deployer.deploy(HallOfLapgend1);
  await deployer.deploy(HallOfLapgend2);
  await deployer.deploy(HallOfLapgend3);
  await deployer.deploy(HallOfLapgend4);
};
