var Whitelist = artifacts.require("./Base/Whitelist.sol");

require('dotenv').config();

module.exports = function (deployer, network) {
    switch (network){
        case 'development':
            deployer.deploy(Whitelist);
            break;
        case 'ropsten':
            var WhitelistAddress = process.env.WHITELIST_ROPSTEN_ADDRESS;

            if(!WhitelistAddress) {
                deployer.deploy(WhitelistAddress);
            }
            break;
        case 'kovan':
            var WhitelistAddress = process.env.WHITELIST_KOVAN_ADDRESS;

            if(!WhitelistAddress) {
                deployer.deploy(WhitelistAddress);
            }
            break;
        case 'main':
            var WhitelistAddress = process.env.WHITELIST_MAINNET_ADDRESS;

            if(!WhitelistAddress) {
                deployer.deploy(WhitelistAddress);
            }
            break;
        default:
            throw `Unknown network "${network}". See your Truffle configuration file for available networks.` ;

    }
};