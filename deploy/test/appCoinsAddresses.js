var AppCoinAddresses = artifacts.require("./AppCoinsAddresses.sol");
var expect = require("chai").expect;

contract('AppCoinAddresses', function(accounts) {
	var instance;

	beforeEach('Setting AppCoinsAddresses test...', async function(){
		instance = await AppCoinAddresses.new();
	})

	it("it should the the address", async function(){
		console.log(instance);
		// var total_supply = await instance.totalSupply.call();
		// var balance1 = await instance.balanceOf.call(accounts[0], {from: accounts[0]});
		//
		// expect(Number(balance1)).to.be.equal(Number(total_supply));
	})

});
