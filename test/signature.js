const Signature = artifacts.require("./Base/Signature.sol");
const chai = require('chai');
const Web3 = require('web3');
var TestUtils = require('./TestUtils.js');
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

        const expectedAddress = await signatureInstance.recoverSigner(objSign.messageHash, objSign.signature);

        expect(address).to.be.equal(expectedAddress, "The addresses do not match");

	})

        it('should get the address with a message and a signature',async function () {
                privateKey8 = "0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501208";
                const signatureInstance = await Signature.new();
                var bid = web3.utils.toHex("0x0000000000000000000000000000000000000000000000000000000000000001");
		var timestamp = Date.now();
		var hash = bid;
		var buf = new Buffer(4);
		buf.writeUInt8(0x1, 3);
		var msgList = [Buffer.alloc(26),Buffer.from(hash),Buffer.alloc(28),buf];
		var msg = Buffer.concat(msgList);
		
		var signatureObj = await web3.eth.accounts.sign(msg.toString(), privateKey8); 

                const expectedHash = await signatureInstance.hashPersonalMessage(msg.toString());

                expect(expectedHash).to.be.equal(signatureObj.messageHash, "The addresses do not match");
        })
})
