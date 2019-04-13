var Marketplace = artifacts.require("./Marketplace.sol");

contract('Marketplace', function (accounts) {
    const owner = '0xc1C2aC8aA2e8695D7e76eebEDE8d87032A7Dee64'.toLowerCase();
    const alice = '0x35EF925361C92F3fC97e224bE43291cdBA1CDB25'.toLowerCase();
    const bob = '0x0D546082197a350479502282cabfF8e48e908f81'.toLowerCase();

    it("should register users with their roles", async () => {
        const marketplace = await Marketplace.deployed();
        const ownerName = "Peter";

        const ownerTransaction = await marketplace.addUser(ownerName, "Administrator", {
            from: owner
        });
        const aliceTransaction = await marketplace.addUser("Alice", "Store Owner", {
            from: alice
        });
        const bobTransaction = await marketplace.addUser("Bob", "Buyer", {
            from: bob
        });
        assert.equal(ownerTransaction.receipt.from.toString(),owner,"Invalid registration");
        assert.equal(aliceTransaction.receipt.from.toString(),alice,"Invalid registration");
        assert.equal(bobTransaction.receipt.from.toString(),bob,"Invalid registration");
    });
    it("should return user's role", async () => {
        const marketplace = await Marketplace.deployed();

        const ownerResult = await marketplace.checkUser({
            from: owner
        });
        const aliceResult = await marketplace.checkUser({
            from: alice
        });
        const bobResult = await marketplace.checkUser({
            from: bob
        });
        const unknownResult = await marketplace.checkUser({
            from: '0x0000000000000000000000000000000000000001'
        });
        assert.equal(ownerResult, 0, "user must be administrator");
        assert.equal(aliceResult, 1, "user must be store owner");
        assert.equal(bobResult, 2, "user must be buyer");
    });
    it("should not return user's role", async () => {
        const marketplace = await Marketplace.deployed();

        const unknownResult = await marketplace.checkUser({
            from: '0x0000000000000000000000000000000000000001'
        });
        assert.equal(unknownResult, 3, "unknown user must be default enum value - Unknown");
    });
    it("should create a store", async () => {
        const marketplace = await Marketplace.deployed();

        const aliceStoreTransaction = await marketplace.addStore("Alice's Store", {
            from: alice
        });
        const aliceFirstStore = await marketplace.getStoreOwnerStoreNames({
            from: alice
        });
        assert.equal(aliceFirstStore, "Alice's Store", "store owner must create a store");
        await marketplace.addStore("Alice's Store1", {
            from: alice
        });
        await marketplace.addStore("Alice's Store2", {
            from: alice
        });
        await marketplace.addStore("Alice's Store3", {
            from: alice
        });
        const aliceTotalStores = await marketplace.getStoreOwnerStoreNames({
            from: alice
        });
        assert.equal(aliceTotalStores.length, 4, "store owner must be able to create more than one store");
    });
})