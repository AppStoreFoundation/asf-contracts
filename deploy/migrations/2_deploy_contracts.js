var AppCoins = artifacts.require("./AppCoins.sol");
var AppCoinsBClass = artifacts.require("./AppCoinsBClass.sol");
var AppCoinsIAB = artifacts.require("./AppCoinsIAB.sol");
var AppCoinsAddresses = artifacts.require("./AppCoinsAddresses.sol");
var Advertisement = artifacts.require("./Advertisement.sol");

module.exports = function(deployer, network) {

    switch (network) {
        case 'development':
            deployer.deploy(AppCoins).then(function() {
                deployer.deploy(AppCoinsIAB);
                deployer.deploy(Advertisement, AppCoins.address);
                deployer.deploy(AppCoinsBClass, AppCoins.address);
            })
            deployer.deploy(AppCoinsAddresses);
            break;

        case 'ropsten':
            AppCoinsAddress = '0xab949343E6C369C6B17C7ae302c1dEbD4B7B61c3';

            if (!AppCoinsAddress) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(AppCoinsIAB);
            deployer.deploy(Advertisement, AppCoinsAddress);
            deployer.deploy(AppCoinsBClass, AppCoinsAddress);
            deployer.deploy(AppCoinsAddresses);
            break;

        case 'kovan':
            deployer.deploy(AppCoins).then(function() {
                deployer.deploy(AppCoinsIAB);
                deployer.deploy(Advertisement, AppCoins.address);
                deployer.deploy(AppCoinsBClass, AppCoins.address);
            })
            break;

        case 'main':
            var AppCoinsAddress = '';

            if (!AppCoinsAddress) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(AppCoinsIAB);
            deployer.deploy(Advertisement, AppCoinsAddress);
            deployer.deploy(AppCoinsBClass, AppCoinsAddress);
            deployer.deploy(AppCoinsAddresses);
            break;

        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.` ;

    }
};
