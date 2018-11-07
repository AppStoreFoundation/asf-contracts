var AppCoinsIAB = artifacts.require("./AppCoinsIAB.sol");
var Shares = artifacts.require('./lib/Shares.sol');
require('dotenv').config();

module.exports = async function(deployer, network) {
    switch (network) {
        case 'coverage':
        case 'development':
            Shares.deployed()
            .then(async () => {
                await deployer.link(Shares, AppCoinsIAB);
                return deployer.deploy(AppCoinsIAB);
            })

            break;

        case 'ropsten':
            var AppCoinsIABAddress = process.env.IAB_ROPSTEN_ADDRESS;


            if (!AppCoinsIABAddress) {
                Shares.deployed()
                .then(async () => {
                    await deployer.link(Shares, AppCoinsIAB);
                    return deployer.deploy(AppCoinsIAB);
                })
            }

            break;

        case 'kovan':
            var AppCoinsIABAddress = process.env.IAB_KOVAN_ADDRESS;

            if (!AppCoinsAddress) {
                Shares.deployed()
                .then(async () => {
                    await deployer.link(Shares, AppCoinsIAB);
                    return deployer.deploy(AppCoinsIAB);
                })                
            }

            break;

        case 'main':
            var AppCoinsIABAddress = process.env.IAB_MAINNET_ADDRESS;

            if (!AppCoinsIABAddress) {
                Shares.deployed()
                .then(async () => {
                    await deployer.link(Shares, AppCoinsIAB);
                    return deployer.deploy(AppCoinsIAB);
                })
            }

            break;

        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.` ;

    }
};
