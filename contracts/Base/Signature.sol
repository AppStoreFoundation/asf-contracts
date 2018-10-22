pragma solidity ^0.4.24;

/**
@title AppCoinsTimelock
@author App Store Foundation
@dev Signature contract
*
*/
contract Signature {

    /**
    @notice splitSignature
    @dev
        Based on a signature Sig (bytes32), returns the r, s, v
    @param sig Signature
    @return {
        "uint8" : "recover Id",
        "bytes32" : "Output of the ECDSA signature",
        "bytes32" : "Output of the ECDSA signature",
    }
    */
    function splitSignature(bytes sig)
        internal
        pure
        returns (uint8, bytes32, bytes32)
        {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    /**
    @notice recoverSigner
    @dev
        Based on a message and signature returns the address
    @param message Message
    @param sig Signature
    @return {
        "address" : "Address of the private key that signed",
    }
    */
    function recoverSigner(bytes32 message, bytes sig)
        public
        pure
        returns (address)
        {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }
}
