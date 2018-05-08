var AppCoinAddresses = artifacts.require("./AppCoinsAddresses.sol");
var expect = require("chai").expect;

contract('AppCoinsAddresses', function(accounts) {
	var instance;
	var testAddress = "0x73215a5f1b95ecfb79d37c94fea5c310b039f527";
	var appCoinsTestAddress = "0x74901a5f1b95ecfb79d37c94fea5c310b039f527";
	var appCoinsIABTestAddress = "0xb388fcbf75812a2b25630baf2be307bff4333204";
	var advertisementTestAddress = "0xd2eafa9b3d6ee31c6c1b615e0efa0751d4a892b6";

	beforeEach('Setting AppCoinsAddresses test...', async function(){
		instance = await AppCoinAddresses.new();
	})

	it("it should set AppCoins Address correctly", async function(){
		await instance.setAppCoinsAddress.sendTransaction(appCoinsTestAddress);
		var testAddr = await instance.getAppCoinsAddress.call();

		expect(testAddr).to.be.equal(appCoinsTestAddress);
	})

	it("it should set AppCoinsIAB Address correctly", async function(){
		await instance.setAppCoinsIABAddress.sendTransaction(appCoinsIABTestAddress);
		var testAddr = await instance.getAppCoinsIABAddress.call();

		expect(testAddr).to.be.equal(appCoinsIABTestAddress);
	})

	it("it should set Advertisement Address correctly", async function(){
		await instance.setAdvertisementAddress.sendTransaction(advertisementTestAddress);
		var testAddr = await instance.getAdvertisementAddress.call();

		expect(testAddr).to.be.equal(advertisementTestAddress);
	})

	it("it should set a new Custom Made Address correctly", async function(){
		await instance.addAddress.sendTransaction("testeContractAddress", testAddress);
		var testAddr = await instance.getContractAddressByName.call("testeContractAddress");

		expect(testAddr).to.be.equal(testAddress);
	})

	it("it should update an Address when added a duplicated name", async function(){
		await instance.addAddress.sendTransaction("testeContractAddress", testAddress);
		var auxAddr = await instance.getContractAddressByName.call("testeContractAddress");
		expect(auxAddr).to.be.equal(testAddress);

		//	How many Ids are after adding a new Address
		var availableIds = await instance.getAvailableIds.call();


		//	Tried to add an address with the same name, it should update it
		await instance.addAddress.sendTransaction("testeContractAddress", appCoinsTestAddress);
		var auxAddr2 = await instance.getContractAddressByName.call("testeContractAddress");
		expect(auxAddr2).to.not.equal(auxAddr);
		expect(auxAddr2).to.be.equal(appCoinsTestAddress);

		//	How many Ids are after updating a Address
		var newAvailableIds = await instance.getAvailableIds.call();
		expect(availableIds.length).to.be.equal(newAvailableIds.length);
	})

});
