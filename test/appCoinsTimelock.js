const AppCoins = artifacts.require("./AppCoins.sol");
const AppCoinsTimelock = artifacts.require("./AppCoinsTimelock.sol");
const chai = require('chai');
const web3 = require('web3');
const TestUtils = require('./TestUtils.js');
const expect = chai.expect;
const chaiAsPromissed = require('chai-as-promised');
chai.use(chaiAsPromissed);

const expectRevert = RegExp('revert');

let AppCoinsTimelockInstance;

const testAddresses = [
    '0xc8860e4669cfc6c085ba99728e092698b371b445',
    '0x0f62aac93184ae1e883dfe213f267d88b3c5529a',
    '0x077652ecd31f4b0ae3dd8eb8efe988f75267ff56',
    '0xba0a89b3fa45e2cf94b9e04cb01035f7ff4f9236',
    '0x6564262e87c432c374039058dadaa0f1e2d4dbbf',
];

const testAmounts = [
    10, 2, 3, 4, 100,
];

contract('AppCoinsTimelock', function(accounts) {
    beforeEach('Setting Advertisement test...',async () => {
        appcInstance = await AppCoins.new();
        TestUtils.setAppCoinsInstance(appcInstance);
    });

    it('should store a simple address with a amount', async function () {
        const releaseTime = (new Date()).getTime();

        AppCoinsTimelockInstance = await AppCoinsTimelock.new(appcInstance.address, releaseTime);
        TestUtils.setContractInstance(AppCoinsTimelockInstance);

        await appcInstance.approve(AppCoinsTimelockInstance.address, testAmounts[0], { from: accounts[0] });

        await AppCoinsTimelockInstance.allocateFunds(testAddresses[0], testAmounts[0]);

        const auxBalance =
            await AppCoinsTimelockInstance.getBalanceOf(testAddresses[0]);

        expect(auxBalance.toNumber())
        .to.be.equal(testAmounts[0], "The contract is not saving the correct amount");

    })

    it('should add an amount to a stored address', async function () {
        const releaseTime = (new Date()).getTime();

        AppCoinsTimelockInstance = await AppCoinsTimelock.new(appcInstance.address, releaseTime);
        TestUtils.setContractInstance(AppCoinsTimelockInstance);

        await appcInstance.approve(AppCoinsTimelockInstance.address, testAmounts[0], { from: accounts[0] });

        await AppCoinsTimelockInstance.allocateFunds(testAddresses[0], testAmounts[0]);

        const aditionalAmount = 5;

        //  Add more amounts to the user
        await appcInstance.approve(AppCoinsTimelockInstance.address, aditionalAmount, { from: accounts[0] });

        await AppCoinsTimelockInstance.allocateFunds(testAddresses[0], aditionalAmount);

        const auxBalance = await AppCoinsTimelockInstance.getBalanceOf(testAddresses[0]);

        expect(auxBalance.toNumber())
        .to.be.equal(testAmounts[0] + aditionalAmount, "The contract is not saving the correct amount");

    })

    it('should store a bulk of addresses', async function () {
        const releaseTime = (new Date()).getTime();

        AppCoinsTimelockInstance = await AppCoinsTimelock.new(appcInstance.address, releaseTime);
        TestUtils.setContractInstance(AppCoinsTimelockInstance);

        await appcInstance.approve(AppCoinsTimelockInstance.address, testAmounts[0], { from: accounts[0] });

        let totalamount = 0;

        testAmounts.map((amount) => totalamount += amount);

        await appcInstance.approve(AppCoinsTimelockInstance.address, totalamount, { from: accounts[0] });

        await AppCoinsTimelockInstance.allocateFundsBulk(testAddresses, testAmounts);

        const auxBalance =
            await AppCoinsTimelockInstance.getBalanceOf(testAddresses[0]);

        expect(auxBalance.toNumber())
        .to.be.equal(testAmounts[0], "The contract is not saving the correct bulks amounts");
    })

    it('should enable release funds after time expires', async function () {
        const releaseTime = (new Date("2000-01-01")).getTime();

        AppCoinsTimelockInstance = await AppCoinsTimelock.new(appcInstance.address, releaseTime);
        TestUtils.setContractInstance(AppCoinsTimelockInstance);

        await appcInstance.approve(AppCoinsTimelockInstance.address, testAmounts[0], { from: accounts[0] });

        await AppCoinsTimelockInstance.allocateFunds(testAddresses[0], testAmounts[0]);

        await AppCoinsTimelockInstance.release(testAddresses[0], { from: accounts[0] });

        const auxBalance = await AppCoinsTimelockInstance.getBalanceOf(testAddresses[0]);

        expect(auxBalance.toNumber())
        .to.be.equal(0, "The contract is releasing the correct amount");
    })

    it('should revert if the release time has not expired', async function () {
        const releaseTime = (new Date("2099-01-01")).getTime();

        AppCoinsTimelockInstance = await AppCoinsTimelock.new(appcInstance.address, releaseTime);
        TestUtils.setContractInstance(AppCoinsTimelockInstance);

        await appcInstance.approve(AppCoinsTimelockInstance.address, testAmounts[0], { from: accounts[0] });

        await AppCoinsTimelockInstance.allocateFunds(testAddresses[0], testAmounts[0]);

        await AppCoinsTimelockInstance.release(testAddresses[0], { from: accounts[0] }).catch(
            (err) => {
                reverted = expectRevert.test(err.message);
            });
        expect(reverted).to.be.equal(true,"Revert expected");
    })

});
