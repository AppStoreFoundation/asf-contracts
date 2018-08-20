var AppCoins = artifacts.require("./AppCoins.sol");
var AdvertisementStorage = artifacts.require("./AdvertisementStorage.sol");

require('dotenv').config();

module.exports = function(deployer, network) {
    switch (network) {

        case 'development':

            deployer.deploy(AdvertisementStorage);

            break;

        case 'ropsten':

            deployer.deploy(AdvertisementStorage);

            break;

        case 'kovan':

            deployer.deploy(AdvertisementStorage);

            break;

        case 'main':

            deployer.deploy(AdvertisementStorage);

            break;


        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.` ;

    }
};
