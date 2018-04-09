var AppCoins = artifacts.require("./AppCoins.sol");
var AppCoinsIAB = artifacts.require("./AppCoinsIAB.sol");
var Advertisement = artifacts.require("./Advertisement.sol");

module.exports = function(deployer) {
    deployer.deploy(AppCoins);
    deployer.deploy(AppCoinsIAB);
    deployer.deploy(Advertisement);
};
