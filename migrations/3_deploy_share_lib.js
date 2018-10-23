var Shares = artifacts.require('./lib/Shares.sol');
require('dotenv').config();

module.exports = async function(deployer, network) {
    switch (network) {
        case 'development':
            deployer.deploy(Shares);
            break;

        case 'ropsten':
            var SharesAddress = process.env.SHARES_ROPSTEN_ADDRESS;


            if (!SharesAddress.startsWith("0x")) {
                deployer.deploy(Shares);
            }

            break;

        case 'kovan':
            var SharesAddress = process.env.SHARES_KOVAN_ADDRESS;


            if (!SharesAddress.startsWith("0x")) {
                deployer.deploy(Shares);
            }

            break;

        case 'main':
            var SharesAddress = process.env.SHARES_MAINNET_ADDRESS;

            if (!SharesAddress.startsWith("0x")) {
                deployer.deploy(Shares);
            }

            break;


        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.` ;

    }
};
