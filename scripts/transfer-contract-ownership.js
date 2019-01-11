const AddressProxy = artifacts.require("./AddressProxy.sol");
const appCoinsCreditsBalanceInstance = artifacts.require("./AppCoinsCreditsBalance.sol")
const ExtendedAdvertisement = artifacts.require("./ExtendedAdvertisement.sol");
const ExtendedAdvertisementStorage = artifacts.require("./ExtendedAdvertisementStorage.sol");
const ExtendedAdvertisementFinance = artifacts.require("./ExtendedFinance.sol");

const network = process.argv[5] || 'development';
const web3 = require('web3');

require('dotenv').config();

let addressProxyInstance;
let appCoinsCreditsBalanceInstance;
let extendedAdvertisementInstance;
let extendedAdvertisementFinanceInstance;
let extendedAdvertisementStorageInstance;

module.exports = function(callback) {
    switch (network) {

        case 'development':
            addressProxyInstance = AddressProxy.at(process.env.ADDRESS_PROXY_DEVELOPMENT_ADDRESS);
            appCoinsCreditsBalanceInstance = AddressProxy.at(process.env.APPCOINS_CREDITS_BALANCE_DEVELOPMENT_ADDRESS);
            extendedAdvertisementInstance = ExtendedAdvertisement.at(process.env.EXTENDED_ADVERTISEMENT_DEVELOPMENT_ADDRESS);
            extendedAdvertisementFinanceInstance = ExtendedAdvertisementFinance.at(process.env.EXTENDED_ADVERTISEMENT_FINANCE_DEVELOPMENT_ADDRESS);
            extendedAdvertisementStorageInstance = ExtendedAdvertisementStorage.at(process.env.EXTENDED_ADVERTISEMENT_STORAGE_DEVELOPMENT_ADDRESS);

            break;

        case 'ropsten':
            addressProxyInstance = AddressProxy.at(process.env.ADDRESS_PROXY_ROPSTEN_ADDRESS);
            appCoinsCreditsBalanceInstance = AddressProxy.at(process.env.APPCOINS_CREDITS_BALANCE_ROPSTEN_ADDRESS);
            extendedAdvertisementInstance = ExtendedAdvertisement.at(process.env.EXTENDED_ADVERTISEMENT_ROPSTEN_ADDRESS);
            extendedAdvertisementFinanceInstance = ExtendedAdvertisementFinance.at(process.env.EXTENDED_ADVERTISEMENT_FINANCE_ROPSTEN_ADDRESS);
            extendedAdvertisementStorageInstance = ExtendedAdvertisementStorage.at(process.env.EXTENDED_ADVERTISEMENT_STORAGE_ROPSTEN_ADDRESS);

            break;

        case 'main':
            addressProxyInstance = AddressProxy.at(process.env.ADDRESS_PROXY_MAINNET_ADDRESS);
            appCoinsCreditsBalanceInstance = AddressProxy.at(process.env.APPCOINS_CREDITS_BALANCE_MAINNET_ADDRESS);
            extendedAdvertisementInstance = ExtendedAdvertisement.at(process.env.EXTENDED_ADVERTISEMENT_MAINNET_ADDRESS);
            extendedAdvertisementFinanceInstance = ExtendedAdvertisementFinance.at(process.env.EXTENDED_ADVERTISEMENT_MAINNET_ADDRESS);
            extendedAdvertisementStorageInstance = ExtendedAdvertisementStorage.at(process.env.EXTENDED_ADVERTISEMENT_MAINNET_ADDRESS);

            break;

        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.`;

    }

    if(
        !addressProxyInstance ||
        !appCoinsCreditsBalanceInstance ||
        !extendedAdvertisementInstance ||
        !extendedAdvertisementFinanceInstance ||
        !extendedAdvertisementStorageInstance
    ) {
        throw 'Missing environment variables';
    }

    const transferOwnership = function(name, address) {
        addressProxyInstance.addAddress(name, address).then(function(error, success) {
            console.log(`contract ${name} -> ${address}`);
        })
    }

    transferOwnership(process.env.APPCOINSIAB_CONTRACT_NAME, appCoinsIABAddress);
    transferOwnership(process.env.ADVERTISEMENT_CONTRACT_NAME, advertisementAddress);
    transferOwnership(process.env.ADVERTISEMENT_FINANCE_CONTRACT_NAME, advertisementFinanceAddress);
    transferOwnership(process.env.ADVERTISEMENT_STORAGE_CONTRACT_NAME, advertisementStorageAddress);
    transferOwnership(process.env.ADVERTISEMENT_STORAGE_CONTRACT_NAME, advertisementStorageAddress);

};
