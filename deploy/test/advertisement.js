var Advertisement = artifacts.require("./Advertisement.sol");
var AppCoins = artifacts.require("./AppCoins.sol");
var chai = require('chai');
var web3 = require('web3');
var expect = chai.expect;
var chaiAsPromissed = require('chai-as-promised');
chai.use(chaiAsPromissed);
var appcInstance;
var addInstance;
contract('Advertisement', function(accounts) {
  beforeEach(async () => {
		
		appcInstance = await AppCoins.new();
		
		addInstance = await	Advertisement.new();

		await appcInstance.approve(addInstance.address,400);
		await addInstance.setAppCoinsAddress(appcInstance.address);
		await addInstance.createCampaign("com.facebook.orca","PT,UK,FR",[1,2],10,200,2000,1922838059980);

		examplePoA = new Object();
		examplePoA.packageName = "com.facebook.orca";
		examplePoA.bid = web3.utils.toHex("0x00000001");
		examplePoA.timestamp = new Array();
		examplePoA.nounce = new Array();
		for(var i = 0; i < 12; i++){
			examplePoA.timestamp.push(new Date().getTime()+20*i);
			examplePoA.nounce.push(Math.floor(Math.random()*500*i));
		}

	});

	it('should emit an event when PoA is received', function () {
		return addInstance.registerPoA(examplePoA.packageName,examplePoA.bid,examplePoA.timestamp,examplePoA.nounce).then( instance => {
			expect(instance.logs.length).to.be.equal(1);
		});
	});

	it('should revert registerPoA when nounce list and timestamp list have diferent lengths', function () {
		//FIXME expect revert
		addInstance.registerPoA(examplePoA.packageName,examplePoA.bid,examplePoA.timestamp,examplePoA.nounce.splice(2,3));
	});
});
