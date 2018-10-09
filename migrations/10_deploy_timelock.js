var AppCoins = artifacts.require("./AppCoins.sol");
var AppCoinsTimelock = artifacts.require("./AppCoinsTimelock.sol");

require('dotenv').config();

module.exports = function(deployer, network) {
    var releaseTime = (new Date("2019-10-01")).getTime();
    switch (network) {
        case 'development':
            AppCoins.deployed()
            .then(function() {
                return deployer.deploy(AppCoinsTimelock, AppCoins.address, releaseTime);
            })

            break;

        case 'ropsten':
            AppCoinsAddress = process.env.APPCOINS_ROPSTEN_ADDRESS;

            if(!AppCoinsAddress.startsWith("0x")) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(AppCoinsTimelock, AppCoinsAddress, releaseTime);
            break;

        case 'kovan':
            AppCoinsAddress = process.env.APPCOINS_KOVAN_ADDRESS;

            if(!AppCoinsAddress.startsWith("0x")) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(AppCoinsTimelock, AppCoinsAddress, releaseTime);
            break;

        case 'main':
            AppCoinsAddress = process.env.APPCOINS_MAINNET_ADDRESS;

            if(!AppCoinsAddress.startsWith("0x")) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(AppCoinsTimelock, AppCoinsAddress, releaseTime);
            break;

        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.` ;

    }
};
