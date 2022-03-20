const { expectRevert, time } = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const CommentBox = artifacts.require("CommentBox");
const CommentBoxViewer = artifacts.require("CommentBoxViewer");
const ERC20 = artifacts.require("ERC20");

contract("CommentBox Test", (accounts) => {
  beforeEach(async () => {
    token = await ERC20.new(String(100 * 1e18));
    commentBox = await CommentBox.new(accounts[0], token.address, String(1e18));
    viewer = await CommentBoxViewer.new(commentBox.address);
  });

  it("Functional Test", async () => {
    await commentBox.leaveComment("첫번째 댓글.");
    await commentBox.leaveComment("두번째 댓글.");
    await commentBox.leaveComment("세번째 댓글.");
    await commentBox.leaveComment("네번째 댓글.");
    await commentBox.leaveComment("다섯번째 댓글.");

    const res = await viewer.getComments(3);
    console.log(res.comments);
    console.log(res.indices);
  });
});
