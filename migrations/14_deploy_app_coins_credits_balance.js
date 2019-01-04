var AppCoins = artifacts.require("./AppCoins.sol");
var AppCoinsCreditsBalance = artifacts.require("./AppCoinsCreditsBalance.sol");

require('dotenv').config();

module.exports = function(deployer, network) {
    switch (network) {
        case 'coverage':
        case 'development':
            AppCoins.deployed()
            .then(function() {
                return deployer.deploy(AppCoinsCreditsBalance, AppCoins.address);
            })

            break;

        case 'ropsten':
            AppCoinsAddress = process.env.APPCOINS_ROPSTEN_ADDRESS;

            if(!AppCoinsAddress.startsWith("0x")) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(AppCoinsCreditsBalance, AppCoinsAddress);
            break;

        case 'kovan':
            AppCoinsAddress = process.env.APPCOINS_KOVAN_ADDRESS;

            if(!AppCoinsAddress.startsWith("0x")) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(AppCoinsCreditsBalance, AppCoinsAddress);
            break;

        case 'main':
            AppCoinsAddress = process.env.APPCOINS_MAINNET_ADDRESS;

            if(!AppCoinsAddress.startsWith("0x")) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(AppCoinsCreditsBalance, AppCoinsAddress);
            break;

        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.` ;

    }
};
