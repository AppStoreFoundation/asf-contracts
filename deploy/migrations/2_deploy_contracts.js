var AppCoin = artifacts.require("./AppCoin.sol");
var AppCoin2 = artifacts.require("./AppCoin2.sol");
var AppCoinsIAB = artifacts.require("./AppCoinsIAB.sol");
var Advertisement = artifacts.require("./Advertisement.sol");

module.exports = function(deployer) {
    deployer.deploy(AppCoin);
    deployer.deploy(AppCoin2);
    deployer.deploy(AppCoinsIAB);
    deployer.deploy(Advertisement);
};
