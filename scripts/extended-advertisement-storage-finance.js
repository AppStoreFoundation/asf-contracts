const ExtendedAdvertisementStorage = artifacts.require("./ExtendedAdvertisementStorage.sol");
const ExtendedAdvertisementFinance = artifacts.require("./ExtendedFinance.sol");
const Advertisement = artifacts.require("./Advertisement.sol");
const network = process.argv[5] || 'development';
const web3 = require('web3');

require('dotenv').config();

module.exports = function(callback) {
    let extendedStorageInstance;
    let extendedFinanceInstance;
    let extendedAdvertisementStorageAddress;

    switch (network) {

        case 'development':
            extendedStorageInstance = ExtendedExtendedAdvertisementStorage.at(process.env.EXTENDED_ADVERTISEMENT_STORAGE_DEVELOPMENT_ADDRESS);
            extendedFinanceInstance = ExtendedExtendedAdvertisementFinance.at(process.env.EXTENDED_ADVERTISEMENT_FINANCE_DEVELOPMENT_ADDRESS);
            extendedAdvertisementAddress = process.env.EXTENDED_ADVERTISEMENT_DEVELOPMENT_ADDRESS;
            extendedAdvertisementStorageAddress = process.env.EXTENDED_ADVERTISEMENT_STORAGE_DEVELOPMENT_ADDRESS;
            break;

        case 'ropsten':
            extendedStorageInstance = ExtendedAdvertisementStorage.at(process.env.EXTENDED_ADVERTISEMENT_STORAGE_ROPSTEN_ADDRESS);
            extendedFinanceInstance = ExtendedAdvertisementFinance.at(process.env.EXTENDED_ADVERTISEMENT_FINANCE_ROPSTEN_ADDRESS);
            extendedAdvertisementAddress = process.env.EXTENDED_ADVERTISEMENT_ROPSTEN_ADDRESS;
            extendedAdvertisementStorageAddress = process.env.EXTENDED_ADVERTISEMENT_STORAGE_ROPSTEN_ADDRESS;
            break;

        case 'main':
            extendedStorageInstance = ExtendedAdvertisementStorage.at(process.env.EXTENDED_ADVERTISEMENT_STORAGE_MAINNET_ADDRESS);
            extendedFinanceInstance = ExtendedAdvertisementFinance.at(process.env.EXTENDED_ADVERTISEMENT_FINANCE_MAINNET_ADDRESS);
            extendedAdvertisementAddress = process.env.EXTENDED_ADVERTISEMENT_MAINNET_ADDRESS;
            extendedAdvertisementStorageAddress = process.env.EXTENDED_ADVERTISEMENT_STORAGE_MAINNET_ADDRESS;
            break;

        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.`;

    }

    if(!extendedStorageInstance || !extendedAdvertisementAddress) {
        throw 'Missing environment variables';
    }

    const addNewAdvertisementToStorage = function(newAdvertisementAddress) {
        extendedStorageInstance.addAddressToWhitelist(newAdvertisementAddress).then(function(error, success) {
            console.log(`New Extended Advertisement address ${newAdvertisementAddress} added to the storage!`);
        })
    }


    const addAdvertisementContractAddressToFinance = function(newAdvertisementAddress) {
        extendedFinanceInstance.setAllowedAddress(newAdvertisementAddress).then(function(error, success) {
            console.log(`New Extended Advertisement address ${newAdvertisementAddress} added to the finance!`);
        })
    }

    const addAdvertisementStorageContractAddressToFinance = function(newAdvertisementAddress) {
        extendedFinanceInstance.setAdsStorageAddress(newAdvertisementAddress).then(function(error, success) {
            console.log(`New Extended Advertisement address ${newAdvertisementAddress} added to the storage!`);
        })
    }

    //  Run each script in sequence 
    addAdvertisementContractAddressToFinance(extendedAdvertisementAddress);
    addAdvertisementStorageContractAddressToFinance(extendedAdvertisementStorageAddress);
    addNewAdvertisementToStorage(extendedAdvertisementAddress);

};
