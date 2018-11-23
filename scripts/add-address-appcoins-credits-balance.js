const ExtendedAdvertisement = artifacts.require("./ExtendedAdvertisement.sol");
const network = process.argv[5] || 'development';
const web3 = require('web3');

require('dotenv').config();

module.exports = function(callback) {
    let appCoinsCreditsBalanceInstance;

    switch (network) {

        case 'development':
            appCoinsCreditsBalanceInstance = ExtendedAdvertisement.at(process.env.APPCOINS_CREDITS_BALANCE_DEVELOPMENT_ADDRESS);
            break;

        case 'ropsten':
            appCoinsCreditsBalanceInstance = ExtendedAdvertisement.at(process.env.APPCOINS_CREDITS_BALANCE_ROPSTEN_ADDRESS);

            break;

        case 'main':
            appCoinsCreditsBalanceInstance = ExtendedAdvertisement.at(process.env.APPCOINS_CREDITS_BALANCE_MAINNET_ADDRESS);


            break;

        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.`;

    }

    if(!appCoinsCreditsBalanceInstance) {
        throw 'Missing environment variables';
    }

    const addNewAllowedAddress = function(address) {
        appCoinsCreditsBalanceInstance.addAddressToWhitelist(address).then(function(error, success) {
            console.log(`New address ${address} added to the Appcoin credits balance!`);
        })
    }

    // const address = "0x31a16aDF2D5FC73F149fBB779D20c036678b1bBD";
    const address = process.argv[7];

    addNewAllowedAddress(address);

};
