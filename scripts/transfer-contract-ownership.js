const AddressProxy = artifacts.require("./AddressProxy.sol");
const appCoinsCreditsBalance = artifacts.require("./AppCoinsCreditsBalance.sol")
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
            appCoinsCreditsBalanceInstance = appCoinsCreditsBalance.at(process.env.APPCOINS_CREDITS_BALANCE_DEVELOPMENT_ADDRESS);
            extendedAdvertisementInstance = ExtendedAdvertisement.at(process.env.EXTENDED_ADVERTISEMENT_DEVELOPMENT_ADDRESS);
            extendedAdvertisementFinanceInstance = ExtendedAdvertisementFinance.at(process.env.EXTENDED_ADVERTISEMENT_FINANCE_DEVELOPMENT_ADDRESS);
            extendedAdvertisementStorageInstance = ExtendedAdvertisementStorage.at(process.env.EXTENDED_ADVERTISEMENT_STORAGE_DEVELOPMENT_ADDRESS);

            break;

        case 'ropsten':
            addressProxyInstance = AddressProxy.at(process.env.ADDRESS_PROXY_ROPSTEN_ADDRESS);
            appCoinsCreditsBalanceInstance = appCoinsCreditsBalance.at(process.env.APPCOINS_CREDITS_BALANCE_ROPSTEN_ADDRESS);
            extendedAdvertisementInstance = ExtendedAdvertisement.at(process.env.EXTENDED_ADVERTISEMENT_ROPSTEN_ADDRESS);
            extendedAdvertisementFinanceInstance = ExtendedAdvertisementFinance.at(process.env.EXTENDED_ADVERTISEMENT_FINANCE_ROPSTEN_ADDRESS);
            extendedAdvertisementStorageInstance = ExtendedAdvertisementStorage.at(process.env.EXTENDED_ADVERTISEMENT_STORAGE_ROPSTEN_ADDRESS);

            break;

        case 'main':
            addressProxyInstance = AddressProxy.at(process.env.ADDRESS_PROXY_MAINNET_ADDRESS);
            appCoinsCreditsBalanceInstance = appCoinsCreditsBalance.at(process.env.APPCOINS_CREDITS_BALANCE_MAINNET_ADDRESS);
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

    const address = process.argv[7];

    console.log(address);
    const transferOwnership = function(newAddress) {
        addressProxyInstance.transferOwnership(newAddress).then(function(error, success) {
            console.log(`contract Address Proxy new owner ${newAddress}`);
        })

        appCoinsCreditsBalanceInstance.transferOwnership(newAddress).then(function(error, success) {
            console.log(`contract AppCoins Credits Balance new owner ${newAddress}`);
        })

        extendedAdvertisementInstance.transferOwnership(newAddress).then(function(error, success) {
            console.log(`contract Extended Advertisement new owner ${newAddress}`);
        })

        extendedAdvertisementFinanceInstance.transferOwnership(newAddress).then(function(error, success) {
            console.log(`contract Extended Advertisement Finance new owner ${newAddress}`);
        })

        extendedAdvertisementStorageInstance.transferOwnership(newAddress).then(function(error, success) {
            console.log(`contract Extended Advertisement Storage new owner ${newAddress}`);
        })
    }

    transferOwnership(address);

};
