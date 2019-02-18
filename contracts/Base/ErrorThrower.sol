pragma solidity 0.4.24;

interface ErrorThrower {
    event Error(string func, string message);
}