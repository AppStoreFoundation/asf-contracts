var AppCoins = artifacts.require("./AppCoins.sol");
var CampaignLibrary = artifacts.require("./lib/CampaignLibrary.sol");
var AdvertisementStorage = artifacts.require("./AdvertisementStorage.sol");
var AdvertisementFinance = artifacts.require("./AdvertisementFinance.sol");
var Advertisement = artifacts.require("./Advertisement.sol");

require('dotenv').config();

module.exports = async function(deployer, network) {
    switch (network) {
        case 'development':
            try {
                const appCoins = await AppCoins.deployed();
                advFinance  = await deployer.deploy(AdvertisementFinance, appCoins.address);
            } catch (e) {
                console.log(e);
            }

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
