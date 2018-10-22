var AppCoins = artifacts.require("./AppCoins.sol");
var ExtendedAdvertisementStorage = artifacts.require("./ExtendedAdvertisementStorage.sol");
var ExtendedFinance = artifacts.require("./ExtendedFinance.sol");
var ExtendedAdvertisement = artifacts.require("./ExtendedAdvertisement.sol");

require('dotenv').config();

module.exports = function(deployer, network) {
    switch (network) {
        case 'development':
            AppCoins.deployed()
            .then(function() {
                return ExtendedAdvertisementStorage.deployed()
            })
            .then(function() {
                return ExtendedFinance.deployed().catch(console.log)
            })
            .then(function() {
                return deployer.deploy(ExtendedAdvertisement, AppCoins.address, ExtendedAdvertisementStorage.address,ExtendedFinance.address);
            });

            break;

        case 'ropsten':
            AppCoinsAddress = process.env.APPCOINS_ROPSTEN_ADDRESS;
            ExtendedFinanceAddress =  process.env.EXTENDED_ADVERTISEMENT_FINANCE_ROPSTEN_ADDRESS;
            ExtendedAdvertisementStorageAddress = process.env.EXTENDED_ADVERTISEMENT_STORAGE_ROPSTEN_ADDRESS;

            if(!AppCoinsAddress.startsWith("0x")) {
                throw 'AppCoins Address not found!'
            }

            if (!ExtendedFinanceAddress.startsWith("0x") || !ExtendedAdvertisementStorageAddress.startsWith("0x")) {
                ExtendedAdvertisementStorage.deployed()
                .then(function() {
                    return ExtendedFinance.deployed()
                })
                .then(function() {
                    return deployer.deploy(ExtendedAdvertisement, AppCoins.address, ExtendedAdvertisementStorage.address,ExtendedFinance.address);
                });

            } else {
                deployer.deploy(ExtendedAdvertisement, AppCoinsAddress, ExtendedAdvertisementStorageAddress, ExtendedFinanceAddress);
            }

            break;

        case 'kovan':
            AppCoinsAddress = process.env.APPCOINS_KOVAN_ADDRESS;
            ExtendedFinanceAddress =  process.env.EXTENDED_ADVERTISEMENT_FINANCE_KOVAN_ADDRESS;
            ExtendedAdvertisementStorageAddress = process.env.EXTENDED_ADVERTISEMENT_STORAGE_KOVAN_ADDRESS;

            if(!AppCoinsAddress.startsWith("0x")) {
                throw 'AppCoins Address not found!'
            }

            if (!ExtendedFinanceAddress.startsWith("0x") || !ExtendedAdvertisementStorageAddress.startsWith("0x")) {
                ExtendedAdvertisementStorage.deployed()
                .then(function() {
                    return ExtendedFinance.deployed()
                })
                .then(function() {
                    return deployer.deploy(ExtendedAdvertisement, AppCoins.address, ExtendedAdvertisementStorage.address,ExtendedFinance.address);
                });

            } else {
                deployer.deploy(ExtendedAdvertisement, AppCoinsAddress, ExtendedAdvertisementStorageAddress, ExtendedFinanceAddress);
            }

            break;

        case 'main':

            AppCoinsAddress = process.env.APPCOINS_MAINNET_ADDRESS;
            ExtendedFinanceAddress =  process.env.EXTENDED_ADVERTISEMENT_FINANCE_MAINNET_ADDRESS;
            ExtendedAdvertisementStorageAddress = process.env.EXTENDED_ADVERTISEMENT_STORAGE_MAINNET_ADDRESS;

            if(!AppCoinsAddress.startsWith("0x")) {
                throw 'AppCoins Address not found!'
            }

            if (!ExtendedFinanceAddress.startsWith("0x") || !ExtendedAdvertisementStorageAddress.startsWith("0x")) {
                ExtendedAdvertisementStorage.deployed()
                .then(function() {
                    return ExtendedFinance.deployed()
                })
                .then(function() {
                    return deployer.deploy(ExtendedAdvertisement, AppCoins.address, ExtendedAdvertisementStorage.address,ExtendedFinance.address);
                });

            } else {
                deployer.deploy(ExtendedAdvertisement, AppCoinsAddress, ExtendedAdvertisementStorageAddress, ExtendedFinanceAddress);
            }

            break;

        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.` ;

    }
};
