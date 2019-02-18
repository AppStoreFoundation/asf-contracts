pragma solidity 0.4.24;

/**
@title AppCoinsTimelock
@author App Store Foundation
@dev Signature contract
*
*/
contract Signature {
    bytes constant public PersonalMessagePrefixBytes = "\x19Ethereum Signed Message:\n";

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
    /**
    @notice hashPersonalMessage function
    @dev
        Based on a message the function generates the hash used for signing the message
    @param _message message to be hashed
    @return {
        "_hash" : "Message hash used for signing the message"
    }
     */
    function hashPersonalMessage(bytes _message) public pure returns (bytes32 _hash) {
        uint256 length = _message.length;
        _hash = keccak256(PersonalMessagePrefixBytes, uintBytes(length), _message);
        return _hash;
    }

    /**
    @notice uintBytes internal function
    @dev
        Function to convert a integer to a dynamic byte array
    @param len Number to be converted
    @return {
        "s" : "Number converted to bytes"
    }
    */
    function uintBytes(uint256 len) internal pure returns (bytes memory s){
        uint256 number = len;
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint256 i = 0;
        while (number != 0) {
            uint256 remainder = number % 10;
            number = number / 10;
            reversed[i++] = byte(48 + remainder);
        }
        s = new bytes(i);
        for (uint256 j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }
        return s;
    }

}
