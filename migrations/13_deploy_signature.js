var Signature = artifacts.require('./Base/Signature.sol');
require('dotenv').config();

module.exports = async function(deployer, network) {
    switch (network) {
        case 'development':
            deployer.deploy(Signature);
            break;

        case 'ropsten':
            var SignatureAddress = process.env.SIGNATURE_ROPSTEN_ADDRESS;


            if (!SignatureAddress.startsWith("0x")) {
                deployer.deploy(Signature);
            }

            break;

        case 'kovan':
            var SignatureAddress = process.env.SIGNATURE_KOVAN_ADDRESS;


            if (!SignatureAddress.startsWith("0x")) {
                deployer.deploy(Signature);
            }
            
            break;

        case 'main':
            var SignatureAddress = process.env.SIGNATURE_MAINNET_ADDRESS;

            if (!SignatureAddress.startsWith("0x")) {
                deployer.deploy(Signature);
            }

            break;


        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.` ;

    }
};
