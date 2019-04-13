const SupplyChain = artifacts.require("./SupplyChain.sol");

contract('SupplyChain', (accounts) => {
    it('should add an item'), async() => {
        const supplyChainInstance = await SupplyChain.deployed();
        await addItem('product',20);
        const addedItem = supplyChainInstance.items[1];
        assert.equal(items.length, 1,"product not added");
        assert.equal(items[0].sku, 1,"wrong item");
    }
})