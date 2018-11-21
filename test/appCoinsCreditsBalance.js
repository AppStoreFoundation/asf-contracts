const AppCoins = artifacts.require("./AppCoins.sol");
const AppCoinsCreditsBalance = artifacts.require("./AppCoinsCreditsBalance.sol");
const chai = require('chai');
const web3 = require('web3');
const TestUtils = require('./TestUtils.js');
const expect = chai.expect;
const chaiAsPromissed = require('chai-as-promised');
chai.use(chaiAsPromissed);

const expectRevert = RegExp('revert');

let appcInstance;
let appCoinsCreditsBalanceInstance;

contract('AppCoinsCredits', function(accounts) {
    beforeEach('Setting Advertisement test...',async () => {
        appcInstance = await AppCoins.new();
        TestUtils.setAppCoinsInstance(appcInstance);

        appCoinsCreditsBalanceInstance = await AppCoinsCreditsBalance.new(appcInstance.address);
        TestUtils.setContractInstance(appCoinsCreditsBalanceInstance);
        await AdvertisementStorageInstance.addAddressToWhitelist(accounts[0]);

    });

    it('event is send after a register balance proof', async function () {
        appCoinsCreditsBalanceInstance
    })

    it('should recieve APPC correctly', async function () {
        const amount = 10;
        await appcInstance.approve(AppCoinsTimelockInstance.address, amount, { from: accounts[0] });

        await AppCoinsTimelockInstance.depositFunds(amount);


    })

    it('should transfer APPC correctly', async function () {

    })

});
