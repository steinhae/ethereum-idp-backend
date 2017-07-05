pragma solidity ^0.4.0;

contract SimpleStorage {
    uint storedData;

    function setPenis(uint x) {
        storedData = x;
    }

    function getPenis() constant returns (uint) {
        return (storedData * 3);
    }
}