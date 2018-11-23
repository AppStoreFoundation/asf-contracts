const AppCoins = artifacts.require("./AppCoins.sol");
const AppCoinsCreditsBalance = artifacts.require("./AppCoinsCreditsBalance.sol");
const chai = require('chai');
const Web3 = require('web3');
const TestUtils = require('./TestUtils.js');
const expect = chai.expect;
const chaiAsPromissed = require('chai-as-promised');
chai.use(chaiAsPromissed);

const expectRevert = RegExp('revert');

let appcInstance;
let appCoinsCreditsBalanceInstance;

contract('AppCoinsCreditsBalance', function(accounts) {
    beforeEach('Setting AppCoinsCreditsBalance test...',async () => {
        appcInstance = await AppCoins.new();
        TestUtils.setAppCoinsInstance(appcInstance);

        appCoinsCreditsBalanceInstance = await AppCoinsCreditsBalance.new(appcInstance.address);
        TestUtils.setContractInstance(appCoinsCreditsBalanceInstance);
        await appCoinsCreditsBalanceInstance.addAddressToWhitelist(accounts[0]);

    });

    it('Should correctly deposit an amount', async function () {
        const amount = 10;
        const firstBalanceProof = Buffer.from(Web3.utils.utf8ToHex("balanceProof")).toString(); //   the balance proof of the first depoit
        const secondBalanceProof = Buffer.from(Web3.utils.utf8ToHex("balanceProof")).toString(); //   the balance proof of the first depoit

        await appcInstance.approve(appCoinsCreditsBalanceInstance.address, amount, { from: accounts[0] });

        await appCoinsCreditsBalanceInstance.depositFunds(amount, firstBalanceProof);

        await TestUtils.expectEventTest('BalanceProof', async () => {
               let expectedBalanceProof = await appCoinsCreditsBalanceInstance.getBalanceProof.call();
               expect(firstBalanceProof)
                .to.be.equal(expectedBalanceProof, "Contrat is not sending the event BalanceProof");
            });

        let auxBalanceProof = await appCoinsCreditsBalanceInstance.getBalanceProof.call();

        expect(auxBalanceProof).to.be.equal(firstBalanceProof, "balanceProof is not stored in the contract");

        let auxBalance =
            await appCoinsCreditsBalanceInstance.getBalance.call();

        expect(auxBalance.toNumber()).to.be.equal(amount, "The contract is saving incorrectly the first deposit");

        await appcInstance.approve(appCoinsCreditsBalanceInstance.address, amount, { from: accounts[0] });

        await appCoinsCreditsBalanceInstance.depositFunds(amount, secondBalanceProof);

        await TestUtils.expectEventTest('BalanceProof', async () => {
               let expectedBalanceProof = await appCoinsCreditsBalanceInstance.getBalanceProof.call();
               expect(secondBalanceProof)
                .to.be.equal(expectedBalanceProof, "Contrat is not sending the event BalanceProof");
            });

        auxBalanceProof = await appCoinsCreditsBalanceInstance.getBalanceProof.call();

        expect(auxBalanceProof).to.be.equal(secondBalanceProof, "balanceProof is not stored in the contract");

        auxBalance = await appCoinsCreditsBalanceInstance.getBalance.call();

        expect(auxBalance.toNumber()).to.be.equal(amount * 2, "The contract is saving incorrectly the second deposit");

    })

    it('Should correctly withdraw an amount', async function () {
        const amountToDeposit = 10;
        const depositBalanceProof = Buffer.from(Web3.utils.utf8ToHex("depositBalanceProof")).toString();
        const amountToWithdraw = 5;
        const withdrawBalanceProof = Buffer.from(Web3.utils.utf8ToHex("withdrawBalanceProof")).toString();

        await appcInstance.approve(appCoinsCreditsBalanceInstance.address, amountToDeposit, { from: accounts[0] });

        await appCoinsCreditsBalanceInstance.depositFunds(amountToDeposit, depositBalanceProof);

        await TestUtils.expectEventTest('BalanceProof', async () => {
               var expectedBalanceProof = await appCoinsCreditsBalanceInstance.getBalanceProof.call();
               expect(depositBalanceProof)
                .to.be.equal(expectedBalanceProof, "Contrat is not sending the event BalanceProof");
            });

        let auxBalance =
            await appCoinsCreditsBalanceInstance.getBalance.call();

        expect(auxBalance.toNumber()).to.be.equal(amountToDeposit, "The contract is saving incorrectly the deposit");

        await appCoinsCreditsBalanceInstance.withdrawFunds(amountToWithdraw, withdrawBalanceProof);

        await TestUtils.expectEventTest('BalanceProof', async () => {
               var expectedBalanceProof = await appCoinsCreditsBalanceInstance.getBalanceProof.call();
               expect(withdrawBalanceProof)
                .to.be.equal(expectedBalanceProof, "Contrat is not sending the event BalanceProof");
            });

        auxBalance =
            await appCoinsCreditsBalanceInstance.getBalance.call();

        expect(auxBalance.toNumber()).to.be.equal(amountToDeposit - amountToWithdraw, "The contract is not correctly deducting the withdraw amount");
    })
});
