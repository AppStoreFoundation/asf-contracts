const Signature = artifacts.require("./Base/Signature.sol");
const chai = require('chai');
const Web3 = require('web3');
const expect = chai.expect;
const chaiAsPromissed = require('chai-as-promised')
chai.use(chaiAsPromissed);
const ganache = require('ganache-cli');

const web3 = new Web3(ganache.provider());

contract('Signature', function(accounts) {

	it('should get the address with a message and a signature',async function () {

        const signatureInstance = await Signature.new();

        const privateKey = "0x6b04c8e3bb9969f1455d1ee0d0d22617b84a47d85d0e0fb29498b6e8daa776e6";

        dafaultAccount = web3.eth.accounts.privateKeyToAccount(privateKey);

        const address = "0x33ea3bffd72996a38dd75696383131bbcaa9a975";

        const msg = "Some data to be tested";

        const objSign = await web3.eth.accounts.sign(msg, privateKey);

        const expectedAddress = await signatureInstance.recoverSigner.call(objSign.messageHash, objSign.signature);

        expect(address).to.be.equal(expectedAddress, "The addresses do not match");

	})

})
