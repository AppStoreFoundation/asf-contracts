var AppCoins = artifacts.require("./AppCoins.sol");
var AppCoinsBClass = artifacts.require("./AppCoinsBClass.sol");
var AppCoinsIAB = artifacts.require("./AppCoinsIAB.sol");
var AddressProxy = artifacts.require("./AddressProxy.sol");
var Advertisement = artifacts.require("./Advertisement.sol");

require('dotenv').config();

module.exports = function(deployer, network) {
    switch (network) {
        case 'development':
            deployer.deploy(AppCoins)
            .then(function() {
                return deployer.deploy(AppCoinsIAB);
            })
            .then(function() {
                return deployer.deploy(Advertisement, AppCoins.address);
            })
            .then(function() {
                return deployer.deploy(AppCoinsBClass, AppCoins.address);
            })
            .then(function() {
                //  Deploy the AddressProxy
                return  deployer.deploy(AddressProxy);
            })
            .then(function() {
                //  Is AddressProxy deployed
                return AddressProxy.deployed();
            })
            .then(function(instance) {
                instance.addAddress(process.env.APPCOINS_CONTRACT_NAME, AppCoins.address);
                instance.addAddress(process.env.APPCOINSIAB_CONTRACT_NAME, AppCoinsIAB.address);
                instance.addAddress(process.env.ADVERTISEMENT_CONTRACT_NAME, Advertisement.address);
                instance.addAddress(process.env.APPCOINSBCLASS_CONTRACT_NAME, AppCoinsBClass.address);
                console.log(instance);
            })

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
