var ExtendedFinance = artifacts.require("./ExtendedFinance.sol");
var AppCoins = artifacts.require("./AppCoins.sol");
var chai = require('chai');
var web3 = require('web3');
var expect = chai.expect;
var chaiAsPromissed = require('chai-as-promised');
chai.use(chaiAsPromissed);

var TestUtils = require('./TestUtils.js');

var ExtendedFinanceInstance;
var appcInstance;

var testCampaign = {
    bidId: 123,
    price: 1,
    budget: 10,
    startDate: 500000,
    endDate: 600000,
    valid: true,
    owner: '0x1DD02B96E9D55E16c646d2F21CA93A705ac667Bf',
    ipValidator: 1,
    filters: {
        packageName: "com.test.pn",
        countries: [409], // PT
        vercodes: [1, 2]
    }
};

var expectRevert = RegExp('revert');

contract('ExtendedFinance', function(accounts) {
    beforeEach('Setting Advertisement test...',async () => {
        appcInstance = await AppCoins.new();
        ExtendedFinanceInstance = await ExtendedFinance.new(appcInstance.address);

        ExtendedFinanceInstance.setAdsStorageAddress(accounts[9]);
        TestUtils.setAppCoinsInstance(appcInstance);
        TestUtils.setContractInstance(ExtendedFinanceInstance);

    });


    it('should store a dev balance if it is done from a valid address', async function () {
        var allowedAddress = accounts[0];
        var budget = 50000000000000000;
        var developer = accounts[2];
        var initBalance;
        var finalBalance;
        var initContractBalance = await TestUtils.getBalance(ExtendedFinanceInstance.address);
        var finalContractBalance;
        
        await ExtendedFinanceInstance.setAllowedAddress(allowedAddress);
        initBalance = JSON.parse(await ExtendedFinanceInstance.getUserBalance.call(developer,{from: allowedAddress}));
        await appcInstance.transfer(ExtendedFinanceInstance.address, budget, { from: allowedAddress});
        
        await ExtendedFinanceInstance.increaseBalance(developer, budget,{ from: allowedAddress});
        finalContractBalance = await TestUtils.getBalance(ExtendedFinanceInstance.address);
        finalBalance = JSON.parse(await ExtendedFinanceInstance.getUserBalance.call(developer,{from: allowedAddress}));
        expect(finalBalance).to.be.equal(initBalance+budget,"Balance was not updated");
        expect(finalContractBalance).to.be.equal(initContractBalance+budget,"Contract balance should have been updated");

    })
    it('should revert if the balance is updated by anyone other than the Advertisement Contract', async function () {
    	var reverted = false;
        var invalidAddress = accounts[2];

        var allowedAddress = accounts[1];
        var budget = 50000000000000000;
        var developer = accounts[2];

        await ExtendedFinanceInstance.setAllowedAddress(allowedAddress);

        await appcInstance.transfer(ExtendedFinanceInstance.address, budget, { from: allowedAddress});

        await ExtendedFinanceInstance
        .increaseBalance(developer, budget)
        .catch(
    		(err) => {
    			reverted = expectRevert.test(err.message);
    		});

    	expect(reverted).to.be.equal(true,"Revert expected");
    });

    it('should allow the contract owner to refund a developer (to a third-party)', async function(){
        var allowedAddress = accounts[1];
        var budget = 50000000000000000;
        var developer = accounts[2];
        var initDeveloperBalance = await TestUtils.getBalance(developer);

        await ExtendedFinanceInstance.setAllowedAddress(allowedAddress);
        
        await appcInstance.transfer(ExtendedFinanceInstance.address, budget);
       
        await ExtendedFinanceInstance.increaseBalance(developer, budget,{ from: allowedAddress});
        var contractBalance = await TestUtils.getBalance(ExtendedFinanceInstance.address);
        expect(contractBalance).to.be.equal(budget,"Contract should hold funds after transfer");
        
        await ExtendedFinanceInstance.withdraw(developer,budget,{from: allowedAddress});
        var contractBalance = await TestUtils.getBalance(ExtendedFinanceInstance.address);
        var finalDeveloperBalance = await TestUtils.getBalance(developer);

        expect(contractBalance).to.be.equal(0,"Contract should hold no funds after refund");
        expect(finalDeveloperBalance).to.be.equal(initDeveloperBalance+budget, "Developer should have his funds returned");

    });
    


    it('should allow the Advertisement Contract to refund a developer (to a third-party)', async function() {
        var allowedAddress = accounts[1];
        var budget = 50000000000000000;
        var developer = accounts[2];
        var initDeveloperBalance = await TestUtils.getBalance(developer);

        await ExtendedFinanceInstance.setAllowedAddress(allowedAddress);

        await appcInstance.transfer(ExtendedFinanceInstance.address, budget);

        await ExtendedFinanceInstance.increaseBalance(developer, budget,{ from: allowedAddress});
        
        await ExtendedFinanceInstance.withdraw(developer,budget,{ from: allowedAddress});
        var finalDeveloperBalance = await TestUtils.getBalance(developer);
        expect(finalDeveloperBalance).to.be.equal(initDeveloperBalance+budget, "Developer should have his funds refunded");
    });

    it('should allow the contract owner to reset the contract refunding the developers with open campaigns', async function() {
        var allowedAddress = accounts[1];
        var budget = 50000000000000000;
        var developers = new Array();
        developers.push(accounts[2]);
        developers.push(accounts[3]);
        var ownerInitialBalance =  await TestUtils.getBalance(accounts[0]);
        var initialbalance2 = await TestUtils.getBalance(developers[0]);
        var initialbalance3 = await TestUtils.getBalance(developers[1]);

        await ExtendedFinanceInstance.setAllowedAddress(allowedAddress);

        await appcInstance.transfer(ExtendedFinanceInstance.address, developers.length*budget)
        
        for (var i = 0; i < developers.length ; i++) {
            await ExtendedFinanceInstance.increaseBalance(developers[i], budget,{ from: allowedAddress});
        }

        expect(await TestUtils.getBalance(ExtendedFinanceInstance.address)).to.be.equal(developers.length * budget,"Coins were not transfered to Finance contract");
        
        await ExtendedFinanceInstance.reset();

        expect(await TestUtils.getBalance(ExtendedFinanceInstance.address)).to.be.equal(0,"Coins were not transfered out of the Finance contract");
        expect(await TestUtils.getBalance(accounts[2])).to.be.equal(initialbalance2 + budget,"Coins were not transfered to developer 2");
        expect(await TestUtils.getBalance(accounts[3])).to.be.equal(initialbalance3 + budget,"Coins were not transfered to developer 3");
        
    });

    it('should allow the Advertisement Contract to reset the contract refunding the developers with open campaigns', async function() {
        var allowedAddress = accounts[1];
        var budget = 50000000000000000;
        var developers = new Array();
        developers.push(accounts[2]);
        developers.push(accounts[3]);
        var initialbalance2 = await TestUtils.getBalance(accounts[2]);
        var initialbalance3 = await TestUtils.getBalance(accounts[3]);

        await ExtendedFinanceInstance.setAllowedAddress(allowedAddress);
        
        await appcInstance.transfer(ExtendedFinanceInstance.address, developers.length*budget)

        for (var i = 0; i < developers.length ; i++) {
            await ExtendedFinanceInstance.increaseBalance(developers[i], budget,{ from: allowedAddress});
        }

        expect(await TestUtils.getBalance(ExtendedFinanceInstance.address)).to.be.equal(developers.length*budget,"Coins were not transfered to Finance contract");
        
        await ExtendedFinanceInstance.reset({ from: allowedAddress });

        expect(await TestUtils.getBalance(accounts[2])).to.be.equal(initialbalance2 + budget,"Coins were not transfered to developer 2");
        expect(await TestUtils.getBalance(accounts[3])).to.be.equal(initialbalance3 + budget,"Coins were not transfered to developer 3");
        expect(await TestUtils.getBalance(ExtendedFinanceInstance.address)).to.be.equal(0,"Coins were not transfered out of the Finance contract");
    });

    it('should allow the Advertisement Contract to make payments through the Advertisement Finance Contract', async function() {
        var allowedAddress = accounts[1];
        var budget = 50000000000000000;
        var developer = accounts[2];
        var initDevBalance = TestUtils.getBalance(developer);

        await ExtendedFinanceInstance.setAllowedAddress(allowedAddress);

        await appcInstance.transfer(ExtendedFinanceInstance.address, budget);

        await ExtendedFinanceInstance.increaseBalance(developer, budget,{ from: allowedAddress});
        
        var initcontractBalance = await TestUtils.getBalance(ExtendedFinanceInstance.address);
        await ExtendedFinanceInstance.pay(developer, accounts[3], budget*0.5, { from: allowedAddress});

        var finalcontractBalance = await TestUtils.getBalance(ExtendedFinanceInstance.address);
        
        expect(initcontractBalance).to.be.equal(finalcontractBalance,"Contract balance should not change after pay function");

        var rewardBalance = JSON.parse(await ExtendedFinanceInstance.getRewardsBalance.call(accounts[3],{ from: allowedAddress}));
        
        await ExtendedFinanceInstance.withdrawRewards(accounts[3], rewardBalance, { from: allowedAddress });
        
        var finalrewardBalance = JSON.parse(await ExtendedFinanceInstance.getRewardsBalance.call(accounts[3],{ from: allowedAddress}));
        expect(finalrewardBalance).to.be.equal(0,"Reward balance not updated")
        expect(await TestUtils.getBalance(accounts[3])).to.be.equal(rewardBalance,"Rewards were not transfered");
  
    });
    
    it('should revert if paying from a developer without coins deposited', async function() {
        var allowedAddress = accounts[1];
        var budget = 50000000000000000;
        var developer = accounts[4];

        await ExtendedFinanceInstance.setAllowedAddress(allowedAddress);

        await appcInstance.transfer(ExtendedFinanceInstance.address, budget);

        await ExtendedFinanceInstance.increaseBalance(developer, budget,{ from: allowedAddress});
        
        await ExtendedFinanceInstance.pay(developer, accounts[3], budget*0.1, { from: allowedAddress});
        await ExtendedFinanceInstance.pay(developer, accounts[4], budget*0.85, { from: allowedAddress});
        await ExtendedFinanceInstance.pay(developer, accounts[5], budget*0.05, { from: allowedAddress});

        await ExtendedFinanceInstance.pay(developer, accounts[3], budget*0.1)
            .catch((err) => {
                reverted = expectRevert.test(err.message);
            });

        expect(reverted).to.be.equal(true,"Revert expected");
    });

    it('should allow to update Storage and reset finance', async function(){
        var allowedAddress = accounts[1];
        var budget = 50000000000000000;
        var developer = accounts[4];
        var initDevBalance =await TestUtils.getBalance(developer);

        await ExtendedFinanceInstance.setAllowedAddress(allowedAddress);

        await appcInstance.transfer(ExtendedFinanceInstance.address, budget);

        await ExtendedFinanceInstance.increaseBalance(developer, budget,{ from: allowedAddress});
            
        var initContractBalance = await TestUtils.getBalance(ExtendedFinanceInstance.address);

        await ExtendedFinanceInstance.setAdsStorageAddress(accounts[8]);

        var finalContractBalance = await TestUtils.getBalance(ExtendedFinanceInstance.address);

        expect(await TestUtils.getBalance(ExtendedFinanceInstance.address)).to.be.equal(0, 'Contract should refund developers');
        expect(await TestUtils.getBalance(developer)).to.be.equal(initDevBalance + budget, 'Developer should receive his share');

    })

    it('should allow a user to withdraw rewards without taking funds destined to user\'s campaigns',async function(){
        var allowedAddress = accounts[1];
        var budget = 50000000000000000;
        var reward = 5000000000000000;
        var developer = accounts[4];
        var initDevBalance =await TestUtils.getBalance(developer);
        var initDevCampaignBalance;
        
        await ExtendedFinanceInstance.setAllowedAddress(allowedAddress);
        await appcInstance.transfer(ExtendedFinanceInstance.address,budget);
        await ExtendedFinanceInstance.increaseBalance(developer, budget,{ from: allowedAddress});
        
        await ExtendedFinanceInstance.pay(developer,developer,reward,{ from: allowedAddress});
        
        initDevCampaignBalance = JSON.parse(await ExtendedFinanceInstance.getUserBalance(developer,{from: allowedAddress}));
        var internalBalance = JSON.parse(await ExtendedFinanceInstance.getRewardsBalance.call(developer,{ from: allowedAddress}));
        
        await ExtendedFinanceInstance.withdrawRewards(developer,internalBalance,{ from: allowedAddress});
        
        var internalfinalBalance = JSON.parse(await ExtendedFinanceInstance.getRewardsBalance.call(developer,{ from: allowedAddress}));
        var finalDevCampaignBalance = JSON.parse(await ExtendedFinanceInstance.getUserBalance(developer,{from: allowedAddress}));
        
        expect(await TestUtils.getBalance(developer)).to.be.equal(initDevBalance + reward, 'Developer should receive his share');
        expect(internalfinalBalance).to.be.equal(0,'All rewards should have been withdrawn');
        expect(initDevCampaignBalance).to.be.not.equal(0,'Developer\'s campaign balance should not be 0');
        expect(initDevCampaignBalance).to.be.equal(finalDevCampaignBalance,'Developer\'s campaign balance should not be changed');
    });
    
});
