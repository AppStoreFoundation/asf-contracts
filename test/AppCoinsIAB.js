var AppCoinsIAB = artifacts.require("./AppCoinsIAB.sol");
var AppCoins = artifacts.require("./AppCoins.sol");
var chai = require('chai');
var web3 = require('web3');
console.log(web3.version);
var expect = chai.expect;
var chaiAsPromissed = require('chai-as-promised')
chai.use(chaiAsPromissed);

var appcInstance;
var appIABInstance;
var userAcc;
var devAcc;
var appStoreAcc;
var oemAcc;

var devShare = 0.85;
var appSShare = 0.1;
var oemShare = 0.05;

async function getBalance(account) {
	return JSON.parse(await appcInstance.balanceOf(account));
}

async function expectErrorMessageTest(errorMessage,callback){
	var price = 10000000;
	var revert = false;
	var events = appIABInstance.allEvents();

	await callback(price);
	var eventLog = await new Promise(
			function(resolve, reject){
	        events.watch(function(error, log){ events.stopWatching(); resolve(log); });
	    });

    assert.equal(eventLog.event, "Error", "Event must be an Error");
    assert.equal(eventLog.args.message,errorMessage,"Event message should be: "+errorMessage);	
}

contract('AppCoinsIAB', function(accounts) {
	beforeEach( async () => {
		appcInstance = await AppCoins.new();
		appIABInstance = await AppCoinsIAB.new();

		userAcc = accounts[0];
		devAcc = accounts[1];
		appStoreAcc = accounts[2];
		oemAcc = accounts[3];

	})

	it('should make a buy',async function () {
		var userInitBalance = await getBalance(userAcc);
		var devInitBalance = await getBalance(devAcc);
		var appSInitBalance = await getBalance(appStoreAcc);
		var oemInitBalance = await getBalance(oemAcc);

		var price = 10000000;
		await appcInstance.approve(appIABInstance.address,price);
		await appIABInstance.buy.sendTransaction(price,"e",appcInstance.address,devAcc,appStoreAcc,oemAcc);

		var userFinalBalance = await getBalance(userAcc);
		var devFinalBalance = await getBalance(devAcc);
		var appSFinalBalance = await getBalance(appStoreAcc);
		var oemFinalBalance = await getBalance(oemAcc);
		
		expect(userFinalBalance).to.be.equal(userInitBalance-price);
		expect(devFinalBalance).to.be.equal(devInitBalance+(price*devShare));
		expect(appSFinalBalance).to.be.equal(appSInitBalance+(price*appSShare));
		expect(oemFinalBalance).to.be.equal(oemInitBalance+(price*oemShare));
	})
	it('should revert and emit an Error event when there is no allowance', async function () {
		await expectErrorMessageTest("Not enough allowance",(price) => {
			return appIABInstance.buy.sendTransaction(price,"example",appcInstance.address,devAcc,appStoreAcc,oemAcc);
		});
	})

})