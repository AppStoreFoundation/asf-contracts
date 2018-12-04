const Advertisement = artifacts.require("./Advertisement.sol");
const network = process.argv[5] || 'development';
const web3 = require('web3');

require('dotenv').config();

module.exports = function(callback) {
    let advertisementInstance;

    switch (network) {

        case 'development':
            advertisementInstance = Advertisement.at(process.env.ADVERTISEMENT_DEVELOPMENT_ADDRESS);
            break;

        case 'ropsten':
            advertisementInstance = Advertisement.at(process.env.ADVERTISEMENT_ROPSTEN_ADDRESS);
            break;

        case 'main':
            advertisementInstance = Advertisement.at(process.env.ADVERTISEMENT_MAINNET_ADDRESS);
            break;

        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.`;

    }

    if(!advertisementInstance) {
        throw 'Missing environment variables';
    }

    const cancelCampaign = function(campaignId) {
        advertisementInstance.cancelCampaign(campaignId).then(function(error, success) {
            console.log(`Campaign ${campaignId} on advertisement at ${process.env.ADVERTISEMENT_MAINNET_ADDRESS} on ${network} successfully canceled!`);
        })
    }

    // const campaignId = '0x000000000000000000000000000000000000000000000000000000000000002';
    const campaignId = process.argv[7];

    cancelCampaign(campaignId);

};
