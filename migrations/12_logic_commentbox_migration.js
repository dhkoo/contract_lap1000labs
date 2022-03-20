const CommentBox = artifacts.require("CommentBox");

module.exports = async function (deployer, network, accounts) {
  if (network == "cypress") {
    await deployer.deploy(CommentBox);
  }
};
