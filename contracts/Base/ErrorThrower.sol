pragma solidity ^0.4.21;

interface ErrorThrower {
    event Error(string func, string message);
}