const AppCoins = artifacts.require("./AppCoins.sol");
const AppCoinsCredits = artifacts.require("./AppCoinsCredits.sol");
const chai = require('chai');
const web3 = require('web3');
const TestUtils = require('./TestUtils.js');
const expect = chai.expect;
const chaiAsPromissed = require('chai-as-promised');
chai.use(chaiAsPromissed);

const expectRevert = RegExp('revert');

let appcInstance;
let AppCoinsCreditsInstance;

contract('AppCoinsCredits', function(accounts) {
    beforeEach('Setting Advertisement test...',async () => {
        appcInstance = await AppCoins.new();
        TestUtils.setAppCoinsInstance(appcInstance);
    });

    it('receives a wallet and merkle tree root hash and dispatch an event', async function () {

    })

    it('should recieve APPC correctly', async function () {

    })

    it('should transfer APPC correctly', async function () {

    })

});
