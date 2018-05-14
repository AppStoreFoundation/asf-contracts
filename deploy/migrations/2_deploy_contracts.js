var AppCoins = artifacts.require("./AppCoins.sol");
var AppCoinsBClass = artifacts.require("./AppCoinsBClass.sol");
var AppCoinsIAB = artifacts.require("./AppCoinsIAB.sol");
var AddressProxy = artifacts.require("./AddressProxy.sol");
var Advertisement = artifacts.require("./Advertisement.sol");

require('dotenv').config();

module.exports = function(deployer, network) {
    switch (network) {
        case 'development':
            deployer.deploy(AppCoins).then(function() {
                deployer.deploy(AppCoinsIAB);
                deployer.deploy(Advertisement, AppCoins.address);
                deployer.deploy(AppCoinsBClass, AppCoins.address);
            })
            deployer.deploy(AddressProxy);
            break;

        case 'ropsten':
            AppCoinsAddress = process.env.APPCOINS_ROPSTEN_ADDRESS;

            if (!AppCoinsAddress) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(AppCoinsIAB);
            deployer.deploy(Advertisement, AppCoinsAddress);
            deployer.deploy(AppCoinsBClass, AppCoinsAddress);
            deployer.deploy(AddressProxy);
            break;

        case 'kovan':
            deployer.deploy(AppCoins).then(function() {
                deployer.deploy(AppCoinsIAB);
                deployer.deploy(Advertisement, AppCoins.address);
                deployer.deploy(AppCoinsBClass, AppCoins.address);
            })
            break;

        case 'main':
            var AppCoinsAddress = process.env.APPCOINS_MAINNET_ADDRESS;

            if (!AppCoinsAddress) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(AppCoinsIAB);
            deployer.deploy(Advertisement, AppCoinsAddress);
            deployer.deploy(AppCoinsBClass, AppCoinsAddress);
            deployer.deploy(AddressProxy);
            break;

        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.` ;

    }
};
