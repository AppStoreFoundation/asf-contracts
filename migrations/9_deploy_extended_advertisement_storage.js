var AppCoins = artifacts.require("./AppCoins.sol");
var ExtendedAdvertisementStorage = artifacts.require("./ExtendedAdvertisementStorage.sol");

require('dotenv').config();

module.exports = function(deployer, network) {
    switch (network) {
        case 'coverage':
        case 'development':

            deployer.deploy(ExtendedAdvertisementStorage);

            break;

        case 'ropsten':

            deployer.deploy(ExtendedAdvertisementStorage);

            break;

        case 'kovan':

            deployer.deploy(ExtendedAdvertisementStorage);

            break;

        case 'main':

            deployer.deploy(ExtendedAdvertisementStorage);

            break;


        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.` ;

    }
};
