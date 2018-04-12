var AppCoins = artifacts.require("./AppCoins.sol");
var AppCoinsIAB = artifacts.require("./AppCoinsIAB.sol");
var Advertisement = artifacts.require("./Advertisement.sol");

module.exports = function(deployer, network) {

    switch (network) {
        case 'development':
            deployer.deploy(AppCoins).then(function() {
                deployer.deploy(AppCoinsIAB);
                deployer.deploy(Advertisement, AppCoins.address);
            })
            break;

        case 'ropsten':
            AppCoinsAddress = '';
            deployer.deploy(AppCoins).then(function() {
                deployer.deploy(AppCoinsIAB);
                deployer.deploy(Advertisement, AppCoins.address);
            })
            break;

        case 'kovan':
            deployer.deploy(AppCoins).then(function() {
                deployer.deploy(AppCoinsIAB);
                deployer.deploy(Advertisement, AppCoins.address);
            })
            break;

        case 'main':
            var AppCoinsAddress = '';

            if(!AppCoinsAddress) {
                throw 'AppCoins Address not found!'
            }
            deployer.deploy(AppCoinsIAB);
            deployer.deploy(Advertisement, AppCoins.address);
            break;

        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.` ;

    }
};
