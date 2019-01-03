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

        const privateKey = "0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501200";

        dafaultAccount = web3.eth.accounts.privateKeyToAccount(privateKey);

        const address = accounts[0];

        const msg = "Some data to be tested";

        const objSign = await web3.eth.accounts.sign(msg, privateKey);

        const expectedAddress = await signatureInstance.recoverSigner.call(objSign.messageHash, objSign.signature);

        expect(address).to.be.equal(expectedAddress, "The addresses do not match");

	})

    it('should get the address with a message and a signature',async function () {

        const privateKey8 = "0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501208";
        const signatureInstance = await Signature.new();
        const bid = web3.utils.toHex("0x0000000000000000000000000000000000000000000000000000000000000001");
		const timestamp = Date.now();
		const hash = bid;
		const buf = new Buffer(4);
		buf.writeUInt8(0x1, 3);
		const msgList = [Buffer.alloc(26),Buffer.from(hash),Buffer.alloc(28),buf];
		const msg = Buffer.concat(msgList);

		const signatureObj = await web3.eth.accounts.sign(msg.toString(), privateKey8);

        const expectedHash = await signatureInstance.hashPersonalMessage(msg.toString());

        expect(expectedHash).to.be.equal(signatureObj.messageHash, "The addresses do not match");
    })

    it('Check that the sender is the one that validated the message', async function () {

        const privateKey = "0x2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501200";
        dafaultAccount = web3.eth.accounts.privateKeyToAccount(privateKey);
        const address = web3.utils.toChecksumAddress(accounts[0]);
        const message = "Hello world";

        const objSign = await web3.eth.accounts.sign(message, privateKey);
        const signature = objSign.signature;

        const expectedSigningAddress = web3.utils.toChecksumAddress(web3.eth.accounts.recover(message, signature));
        expect(expectedSigningAddress).to.equal(address, "The signing address do not match");
    });
})
