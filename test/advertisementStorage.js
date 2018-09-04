var AdvertisementStorage = artifacts.require("./AdvertisementStorage.sol");
var chai = require('chai');
var web3 = require('web3');
var TestUtils = require('./TestUtils.js');
var expect = chai.expect;
var chaiAsPromissed = require('chai-as-promised');
chai.use(chaiAsPromissed);

var AdvertisementStorageInstance;

var testCampaign = {
    bidId: 123,
    price: 1,
    budget: 10,
    startDate: 500000,
    endDate: 600000,
    valid: true,
    owner: '0x1DD02B96E9D55E16c646d2F21CA93A705ac667Bf'
};

var expectRevert = RegExp('revert');

contract('AdvertisementStorage', function(accounts) {
    beforeEach('Setting Advertisement test...',async () => {
        
        AdvertisementStorageInstance = await AdvertisementStorage.new();
        TestUtils.setContractInstance(AdvertisementStorageInstance);
    });

    it('should store a campaign from a valid address', async function () {
        var allowedAddress = accounts[1];
        await AdvertisementStorageInstance.setAllowedAddresses(allowedAddress, true);

        //Add to campaign map
        await AdvertisementStorageInstance.setCampaign(
            testCampaign.bidId,
            testCampaign.price,
            testCampaign.budget,
            testCampaign.startDate,
            testCampaign.endDate,
            testCampaign.valid,
            testCampaign.owner,
            { from: allowedAddress }
        );

        var advertStartDate = 
            await AdvertisementStorageInstance.getCampaignStartDateById.call(testCampaign.bidId);

        expect(JSON.parse(advertStartDate))
        .to.be.equal(testCampaign.startDate, "Campaign was not saved");

    })

    it('should emit a campaign update if the campaign is already created', async function () {
        var allowedAddress = accounts[1];
        await AdvertisementStorageInstance.setAllowedAddresses(allowedAddress, true);

        //Add to campaign map
        await AdvertisementStorageInstance.setCampaign(
            testCampaign.bidId,
            testCampaign.price,
            testCampaign.budget,
            testCampaign.startDate,
            testCampaign.endDate,
            testCampaign.valid,
            testCampaign.owner,
            { from: allowedAddress }
        );

        var advertStartDate = 
            await AdvertisementStorageInstance.getCampaignStartDateById.call(testCampaign.bidId);

        expect(JSON.parse(advertStartDate))
        .to.be.equal(testCampaign.startDate, "Campaign was not saved");

        
        await TestUtils.expectEventTest('CampaignUpdated', async () => {
            await AdvertisementStorageInstance.setCampaignBudgetById(testCampaign.bidId,0);
            
        });

        await TestUtils.expectEventTest('CampaignUpdated', async () => {
            await AdvertisementStorageInstance.setCampaignValidById(testCampaign.bidId, false);
        });


    })

    it('should revert if store a campaign from a invalid address', async function () {
        var invalidAddress = accounts[2];
        
        await TestUtils.expectRevertTest( () => {
            //Add to campaign map
            return AdvertisementStorageInstance.setCampaign(
                testCampaign.bidId,
                testCampaign.price,
                testCampaign.budget,
                testCampaign.startDate,
                testCampaign.endDate,
                testCampaign.valid,
                testCampaign.owner,
                { from: invalidAddress }
            );
        });
    });

    it('should revert if a campaign price is set to a campaign that does not exist', async () => {
        await TestUtils.expectRevertTest( () => {
            
            return AdvertisementStorageInstance.setCampaignPriceById(
                testCampaign.bidId,
                testCampaign.price);
        });
    });
    it('should revert if a campaign budget is set to a campaign that does not exist', async () => {
        await TestUtils.expectRevertTest( () => {
            
            return AdvertisementStorageInstance.setCampaignBudgetById(
                testCampaign.bidId,
                testCampaign.budget);
        });
    });
    it('should revert if a campaign start date is set to a campaign that does not exist', async () => {
        await TestUtils.expectRevertTest( () => {
            
            return AdvertisementStorageInstance.setCampaignStartDateById(
                testCampaign.bidId,
                testCampaign.startDate);
        });
    });

    it('should revert if a campaign end date is set to a campaign that does not exist', async () => {
        await TestUtils.expectRevertTest( () => {
            
            return AdvertisementStorageInstance.setCampaignEndDateById(
                testCampaign.bidId,
                testCampaign.endDate);
        });
    });

    it('should revert if a campaign validity is set to a campaign that does not exist', async () => {
        await TestUtils.expectRevertTest( () => {
            
            return AdvertisementStorageInstance.setCampaignValidById(
                testCampaign.bidId,
                false);
        });
    });

    it('should revert if a campaign owner is set to a campaign that does not exist', async () => {
        await TestUtils.expectRevertTest( () => {
            
            return AdvertisementStorageInstance.setCampaignOwnerById(
                testCampaign.bidId,
                testCampaign.owner);
        });
    });

});
