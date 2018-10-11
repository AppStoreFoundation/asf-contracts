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

    const addNewAllowedAddress = function(address) {
        extendedAdvertisementInstance.addAddressToWhitelist(address).then(function(error, success) {
            console.log(`New address ${address} added to the extended advertisement!`);
        })
    }

    const address = process.argv[7];

    addNewAllowedAddress(address);

};
