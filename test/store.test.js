const { expectRevert, time } = require("@openzeppelin/test-helpers");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const Proxy = artifacts.require("Proxy");
const Store = artifacts.require("Store");
const StoreViewer = artifacts.require("StoreViewer");
const TestNFT = artifacts.require("TestNFT");
const MAX_SIZE =
  "115792089237316195423570985008687907853269984665640564039457584007913129639935";

contract("Store Test", ([dev, seller1, seller2, buyer]) => {
  beforeEach(async () => {
    storeLogic = await Store.new();
    storeProxy = await Proxy.new();
    await storeProxy.upgrade(storeLogic.address);

    store = await Store.at(storeProxy.address);
    await store.initialize(
      dev,
      250, // defaultFeeRatio
      100, // premiumFeeRatio
      2, // GCCount
      10 // GCMaxIter
    );

    viewer = await StoreViewer.new(storeProxy.address);
    testNFT = await TestNFT.new();

    await testNFT.mint(seller1, "");
    await testNFT.mint(seller1, "");
    await testNFT.mint(seller1, "");

    await testNFT.mint(seller2, "");
    await testNFT.mint(seller2, "");
    await testNFT.mint(seller2, "");

    await testNFT.setApprovalForAll(store.address, true, {
      from: seller1,
    });
    await testNFT.setApprovalForAll(store.address, true, {
      from: seller2,
    });
  });

  it("list()", async () => {
    const price = String(1e18);
    const expiredBlockNumber = 100000;
    await store.list(testNFT.address, 1, price, expiredBlockNumber, {
      from: seller1,
    });
    assert.equal(
      seller1,
      await store.itemSeller(testNFT.address, 1),
      "NOT_SELLER"
    );
    const item = await store.userListItems(seller1, 0);
    assert.equal(item.token, testNFT.address, "MISMATCH_TOKEN");
    assert.equal(item.tokenId, 1, "MISMATCH_TOKEN_ID");
    assert.equal(item.price, price, "MISMATCH_PRICE");
  });

  it("cancelList()", async () => {
    const price = String(1e18);
    const expiredBlockNumber = (await web3.eth.getBlockNumber()) + 3600;
    await store.list(testNFT.address, 1, price, expiredBlockNumber, {
      from: seller1,
    });

    await store.cancelList(testNFT.address, 1, { from: seller1 });
    assert.equal(0, await store.userListItemsCount(seller1), "EXIST_LIST");
  });

  it("buy()", async () => {
    const price = String(1e18);
    const expiredBlockNumber = (await web3.eth.getBlockNumber()) + 3600;
    await store.list(testNFT.address, 1, price, expiredBlockNumber, {
      from: seller1,
    });

    await store.buy(testNFT.address, 1, price, {
      from: buyer,
      value: price,
    });

    assert.equal(0, await store.userListItemsCount(seller1), "EXIST_LIST");

    assert.equal(buyer, await testNFT.ownerOf(1), "NOT_ONWER");
    assert.notEqual(seller1, await testNFT.ownerOf(1), "NOT_TRANSFERED");
  });
});
