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
        await AdvertisementStorageInstance.addAddressToWhitelist(allowedAddress);

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
        await AdvertisementStorageInstance.addAddressToWhitelist(allowedAddress);

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

    it('should emit an Error if store a campaign from a invalid address', async function () {
    	var reverted = false;
        var invalidAddress = accounts[2];


        await TestUtils.expectErrorMessageTest(
            'Operation can only be performed by Whitelisted Addresses',
            async () => {
                await AdvertisementStorageInstance.setCampaign(
                    testCampaign.bidId,
                    testCampaign.price,
                    testCampaign.budget,
                    testCampaign.startDate,
                    testCampaign.endDate,
                    testCampaign.valid,
                    testCampaign.owner,
                    { from: invalidAddress }
                )
            });
    });

});
