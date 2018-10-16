var AppCoins = artifacts.require("./AppCoins.sol");
var ExtendedFinance = artifacts.require("./ExtendedFinance.sol");

require('dotenv').config();

module.exports = async function(deployer, network) {
    switch (network) {
        case 'development':
            try {
                const appcoins = await AppCoins.deployed();
                await deployer.deploy(ExtendedFinance,appcoins.address);
            } catch (e) {
                console.log(e);
            }

            break;

        case 'ropsten':
            AppCoinsAddress = process.env.APPCOINS_ROPSTEN_ADDRESS;

            if(!AppCoinsAddress.startsWith("0x")) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(ExtendedFinance, AppCoinsAddress);


            break;

        case 'kovan':

            AppCoinsAddress = process.env.APPCOINS_KOVAN_ADDRESS;

            if(!AppCoinsAddress.startsWith("0x")) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(ExtendedFinance, AppCoinsAddress);

            break;

        case 'main':

            AppCoinsAddress = process.env.APPCOINS_MAINNET_ADDRESS;

            if(!AppCoinsAddress.startsWith("0x")) {
                throw 'AppCoins Address not found!'
            }

            deployer.deploy(ExtendedFinance, AppCoinsAddress);

            break;

        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.` ;

    }
};
