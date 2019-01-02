var ExtendedAdvertisementStorage = artifacts.require("./ExtendedAdvertisementStorage.sol");
var chai = require('chai');
var web3 = require('web3');
var TestUtils = require('./TestUtils.js');
var expect = chai.expect;
var chaiAsPromissed = require('chai-as-promised');
chai.use(chaiAsPromissed);

var extendedAdvertisementStorageInstance;

var testCampaign = {
    bidId: 123,
    price: 1,
    budget: 10,
    startDate: 500000,
    endDate: 600000,
    valid: true,
    owner: '0x1DD02B96E9D55E16c646d2F21CA93A705ac667Bf',
    rewardManager: '0xb9dcbf8a52edc0c8dd9983fcc1d97b1f5d975ed7',
    endPoint: 'http://localhost/api/sign'
};

var bidIdCreation = 1234;

contract('ExtendedAdvertisementStorage', function(accounts) {
    beforeEach('Setting Advertisement test...',async () => {
        
        extendedAdvertisementStorageInstance = await ExtendedAdvertisementStorage.new();
        TestUtils.setContractInstance(extendedAdvertisementStorageInstance);

        await extendedAdvertisementStorageInstance.setCampaign.sendTransaction(
            testCampaign.bidId,
            testCampaign.price,
            testCampaign.budget,
            testCampaign.startDate,
            testCampaign.endDate,
            testCampaign.valid,
            testCampaign.owner,
            testCampaign.rewardManager,
            testCampaign.endPoint
        );

    });

    it('should store a campaign from a valid address', async function () {
        var allowedAddress = accounts[1];

        await extendedAdvertisementStorageInstance.addAddressToWhitelist.sendTransaction(allowedAddress);

        //Add to campaign map
        await extendedAdvertisementStorageInstance.setCampaign.sendTransaction(
            bidIdCreation,
            testCampaign.price,
            testCampaign.budget,
            testCampaign.startDate,
            testCampaign.endDate,
            testCampaign.valid,
            testCampaign.owner,
            testCampaign.rewardManager,
            testCampaign.endPoint,
            { from: allowedAddress }
        );

        var advertStartDate = 
            await extendedAdvertisementStorageInstance.getCampaignStartDateById.call(testCampaign.bidId);

        expect(JSON.parse(advertStartDate))
        .to.be.equal(testCampaign.startDate, "Campaign was not saved");

    })

    it('should emit a campaign update if the campaign is already created', async function () {
        var allowedAddress = accounts[1];
        await extendedAdvertisementStorageInstance.addAddressToWhitelist.sendTransaction(allowedAddress);

        await TestUtils.expectEventTest('ExtendedCampaignUpdated', async () => {
            await extendedAdvertisementStorageInstance.setCampaignEndPointById.sendTransaction(testCampaign.bidId,"https://www.appstorefoundation.org/");
            var endPoint = await extendedAdvertisementStorageInstance.getCampaignEndPointById.call(testCampaign.bidId);
            expect(endPoint)
            .to.be.equal("https://www.appstorefoundation.org/", "Campaign was not updated");
        });

        await TestUtils.expectEventTest('CampaignUpdated', async () => {
            await extendedAdvertisementStorageInstance.setCampaignValidById.sendTransaction(testCampaign.bidId, false);
            var valid = await extendedAdvertisementStorageInstance.getCampaignValidById.call(testCampaign.bidId);
            expect(JSON.parse(valid))
            .to.be.equal(valid, "Campaign was not updated");
        });


    })


    it('should emit an Error if store a campaign from a invalid address', async function () {
        var invalidAddress = accounts[2];
        
            
        await TestUtils.expectErrorMessageTest(
            'Operation can only be performed by Whitelisted Addresses',
            async () => {
                //Add to campaign map
                await extendedAdvertisementStorageInstance.setCampaign(
                bidIdCreation,
                testCampaign.price,
                testCampaign.budget,
                testCampaign.startDate,
                testCampaign.endDate,
                testCampaign.valid,
                testCampaign.owner,
                testCampaign.rewardManager,
                testCampaign.endPoint,
                { from: invalidAddress }
            )
        });
    });


    it('should update a campaign price of an existing campaign', async () => {

        await TestUtils.expectEventTest('CampaignUpdated', async () => {
            await extendedAdvertisementStorageInstance.setCampaignPriceById.sendTransaction(testCampaign.bidId,10);
            var price = await extendedAdvertisementStorageInstance.getCampaignPriceById.call(testCampaign.bidId);
            expect(JSON.parse(price))
                .to.be.equal(10, "Campaign was not updated");
        });
    });

    it('should revert if a campaign price is set to a campaign that does not exist', async () => {
        await TestUtils.expectErrorMessageTest("Campaign does not exist", () => {
            
            return extendedAdvertisementStorageInstance.setCampaignPriceById(
                bidIdCreation,
                testCampaign.price);
        });
    });
   

    it('should update a campaign budget of an existing campaign', async () => {

        await TestUtils.expectEventTest('CampaignUpdated', async () => {
            await extendedAdvertisementStorageInstance
                .setCampaignBudgetById.sendTransaction(testCampaign.bidId,10000);
            var budget = await extendedAdvertisementStorageInstance.getCampaignBudgetById.call(testCampaign.bidId);
            expect(JSON.parse(budget))
                .to.be.equal(10000, "Campaign was not updated");
        });
    });
        
    it('should revert if a campaign budget is set to a campaign that does not exist', async () => {
        await TestUtils.expectErrorMessageTest("Campaign does not exist", () => {
            
            return extendedAdvertisementStorageInstance.setCampaignBudgetById(
                bidIdCreation,
                testCampaign.budget);
            });
    });
            
    it('should update a campaign start date of an existing campaign', async () => {

        await TestUtils.expectEventTest('CampaignUpdated', async () => {
            await extendedAdvertisementStorageInstance
                .setCampaignStartDateById.sendTransaction(testCampaign.bidId,1234438600);
            var startDate = 
                await extendedAdvertisementStorageInstance.getCampaignStartDateById.call(testCampaign.bidId);
            expect(JSON.parse(startDate))
                .to.be.equal(1234438600, "Campaign was not updated");
        });
    });

    it('should revert if a campaign start date is set to a campaign that does not exist', async () => {
        await TestUtils.expectErrorMessageTest("Campaign does not exist", () => {
            
            return extendedAdvertisementStorageInstance.setCampaignStartDateById(
                bidIdCreation,
                testCampaign.startDate);
        });
    });

    it('should update a campaign end date of an existing campaign',async () => {

        await TestUtils.expectEventTest('CampaignUpdated', async () => {
            await extendedAdvertisementStorageInstance
                .setCampaignEndDateById.sendTransaction(testCampaign.bidId,1234438600);
            var endDate = 
                await extendedAdvertisementStorageInstance.getCampaignEndDateById.call(testCampaign.bidId);
            expect(JSON.parse(endDate))
                .to.be.equal(1234438600, "Campaign was not updated");
        });
    });

    it('should update a campaign reward manager address of an existing campaign', async () => {

        await extendedAdvertisementStorageInstance.setRewardManagerById.sendTransaction(
            testCampaign.bidId,
            accounts[9]
        );

        var newRewardManager = await extendedAdvertisementStorageInstance.getRewardManagerById.call(testCampaign.bidId);
        expect(newRewardManager).to.equal(accounts[9],'Reward Manager account was not updated');

    })

    it('should revert if a campaign end date is set to a campaign that does not exist', async () => {
        await TestUtils.expectErrorMessageTest("Campaign does not exist", () => {
            
            return extendedAdvertisementStorageInstance.setCampaignEndDateById(
                bidIdCreation,
                testCampaign.endDate);
        });
    });

    it('should update a campaign validity of an existing campaign', async () => {

        await TestUtils.expectEventTest('CampaignUpdated', async () => {
            await extendedAdvertisementStorageInstance
                .setCampaignValidById.sendTransaction(testCampaign.bidId,false);
            var validity = 
                await extendedAdvertisementStorageInstance.getCampaignValidById.call(testCampaign.bidId);
            expect(JSON.parse(validity))
                .to.be.equal(false, "Campaign was not updated");
        });
    });

    it('should revert if a campaign validity is set to a campaign that does not exist', async () => {
        await TestUtils.expectErrorMessageTest("Campaign does not exist", () => {
            
            return extendedAdvertisementStorageInstance.setCampaignValidById(
                bidIdCreation,
                false);
        });
    });
    
    it('should update a campaign owner of an existing campaign', async () => {

        await TestUtils.expectEventTest('CampaignUpdated', async () => {
            var newOwner = web3.utils.toHex("0x0000000000000000000000000000000000099338");
            await extendedAdvertisementStorageInstance
                .setCampaignOwnerById.sendTransaction(testCampaign.bidId,newOwner);
            var owner = 
                await extendedAdvertisementStorageInstance.getCampaignOwnerById.call(testCampaign.bidId);
            expect(owner)
                .to.be.equal(newOwner, "Campaign was not updated");
        });
    });

    it('should revert if a campaign owner is set to a campaign that does not exist', async () => {
        await TestUtils.expectErrorMessageTest("Campaign does not exist", () => {
            
            return extendedAdvertisementStorageInstance.setCampaignOwnerById(
                bidIdCreation,
                testCampaign.owner);
        });
    });

});
