const { expectRevert, time } = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const ConfigYaml = require("config-yaml");
const lapConfig = ConfigYaml("../lap_config/contracts.yaml");
const UnityViewer = artifacts.require("UnityViewer");

contract("Unity Viewer Test", (accounts) => {
  beforeEach(async () => {
    const alapAddr = lapConfig.cypress.alap;
    const donationAddr = lapConfig.cypress.Donation;
    const nameBookAddr = lapConfig.cypress.NameBook;
    const alapRegistrationAddr = lapConfig.cypress.AlapRegistration;
    const commentBoxAddr = lapConfig.cypress.CommentBox;

    // unityViewer = await UnityViewer.new(
    //   alapAddr,
    //   donationAddr,
    //   nameBookAddr,
    //   alapRegistrationAddr,
    //   commentBoxAddr
    // );
    unityViewer = await UnityViewer.at(
      "0x3c792c83274cF4CEA32bA22bBA674E3A47C49f9a"
    );
  });

  it("getCommentInfos Test", async () => {
    const res = await unityViewer.getCommentInfos(1);
    console.log(res);
  });
});
