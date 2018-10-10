const ExtendedAdvertisement = artifacts.require("./ExtendedAdvertisement.sol");
const network = process.argv[5] || 'development';
const web3 = require('web3');

require('dotenv').config();

module.exports = function(callback) {
    let extendedAdvertisementInstance;

    switch (network) {

        case 'development':
            extendedAdvertisementInstance = ExtendedAdvertisement.at(process.env.EXTENDED_ADVERTISEMENT_DEVELOPMENT_ADDRESS);
            break;

        case 'ropsten':
            extendedAdvertisementInstance = ExtendedAdvertisement.at(process.env.EXTENDED_ADVERTISEMENT_ROPSTEN_ADDRESS);

            break;

        case 'main':
            extendedAdvertisementInstance = ExtendedAdvertisement.at(process.env.EXTENDED_ADVERTISEMENT_MAINNET_ADDRESS);


            break;

        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.`;

    }

    if(!extendedAdvertisementInstance) {
        throw 'Missing environment variables';
    }

    const campaignPrice = 50000000000000000;
  	const campaignBudget = 1000000000000000000;
    const startDate = 20;
    const endDate = 1922838059980;
    const createCampaign = function(address) {
        extendedAdvertisementInstance
            .createCampaign(
                "com.test.extended",
                [0, 114179815416476790484662877555959610910619729920, 0],
                [1],
                campaignPrice,
                campaignPrice,
                1538416080000,
                32472144000000,
                "https://apichain-dev.blockchainds.com/campaign/submitpoa"
            ).then(function(error, success) {
                console.log(`Campaign created`);
        })
    }

    console.log("yoo");
    createCampaign();

};
