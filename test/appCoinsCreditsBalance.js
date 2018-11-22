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

    it('Should correctly send an event after registering a proof of balance', async function () {
        const balanceProof = Buffer.from(Web3.utils.utf8ToHex("balanceProof")).toString();

        await appCoinsCreditsBalanceInstance.registerBalanceProof(balanceProof);

        await TestUtils.expectEventTest('BalanceProof', async () => {
               var expectedBalanceProof = await appCoinsCreditsBalanceInstance.getBbalanceProof.call();
               expect(balanceProof)
                .to.be.equal(expectedBalanceProof, "Contrat do not send event BalanceProof");
            });

        const auxBalanceProof = await appCoinsCreditsBalanceInstance.getBbalanceProof.call();

        expect(auxBalanceProof).to.be.equal(balanceProof, "balanceProof not stored in the contract");


    })

    it('Should correctly deposit an amount', async function () {
        const amount = 10;

        await appcInstance.approve(appCoinsCreditsBalanceInstance.address, amount, { from: accounts[0] });

        await appCoinsCreditsBalanceInstance.depositFunds(amount);

        let auxBalance =
            await appCoinsCreditsBalanceInstance.getBalance.call();

        expect(auxBalance.toNumber()).to.be.equal(amount, "The contract is saving the first deposit");

        await appcInstance.approve(appCoinsCreditsBalanceInstance.address, amount, { from: accounts[0] });

        await appCoinsCreditsBalanceInstance.depositFunds(amount);

        auxBalance = await appCoinsCreditsBalanceInstance.getBalance.call();

        expect(auxBalance.toNumber()).to.be.equal(amount * 2, "The contract is saving heh second deposit");

    })

    it('Should correctly withdraw an amount', async function () {
        const amountToDeposit = 10;
        const amountToWithdraw = 5;

        await appcInstance.approve(appCoinsCreditsBalanceInstance.address, amountToDeposit, { from: accounts[0] });

        await appCoinsCreditsBalanceInstance.depositFunds(amountToDeposit);

        let auxBalance =
            await appCoinsCreditsBalanceInstance.getBalance.call();

        expect(auxBalance.toNumber()).to.be.equal(amountToDeposit, "The contract is saving the first deposit");

        await appCoinsCreditsBalanceInstance.withdrawFunds(amountToWithdraw);

        auxBalance =
            await appCoinsCreditsBalanceInstance.getBalance.call();

        expect(auxBalance.toNumber()).to.be.equal(amountToDeposit - amountToWithdraw, "The contract is saving the first deposit");
    })
});
