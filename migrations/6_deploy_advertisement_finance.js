var AppCoins = artifacts.require("./AppCoins.sol");
var CampaignLibrary = artifacts.require("./lib/CampaignLibrary.sol");
var AdvertisementFinance = artifacts.require("./AdvertisementFinance.sol");

require('dotenv').config();

module.exports = async function(deployer, network) {
    switch (network) {
        case 'coverage':
        case 'development':
            AppCoins.deployed()
            .then(function() {
                return deployer.deploy(AdvertisementFinance, AppCoins.address)
            })

            break;

        case 'ropsten':
            AppCoinsAddress = process.env.APPCOINS_ROPSTEN_ADDRESS;

            if(!AppCoinsAddress.startsWith("0x")) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(AdvertisementFinance, AppCoinsAddress);


            break;

        case 'kovan':

            AppCoinsAddress = process.env.APPCOINS_KOVAN_ADDRESS;

            if(!AppCoinsAddress.startsWith("0x")) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(AdvertisementFinance, AppCoinsAddress);

            break;

        case 'main':

            AppCoinsAddress = process.env.APPCOINS_MAINNET_ADDRESS;

            if(!AppCoinsAddress.startsWith("0x")) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(AdvertisementFinance, AppCoinsAddress);

            break;

        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.` ;

    }
};
