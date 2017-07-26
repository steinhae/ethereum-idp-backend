pragma solidity ^0.4.11;
contract Mortal {
    /* Define variable owner of the type address*/
    address owner;

    /* this function is executed at initialization and sets the owner of the contract */
    function Mortal() {
        owner = msg.sender;
    }

    /* Function to recover the funds on the contract */
    function kill() {
        if (msg.sender == owner) {
            suicide(owner);
        }
    }
}


contract Report {

    uint id;
    uint timeStamp;
    address reporter;
    address[] confirmations;
    bytes32 pictureHash1;
    bytes32 pictureHash2;


    function Report(address sender, bytes32 firstPictureHash, bytes32 secondPictureHash) {
        id = now + msg.gas;
        timeStamp = now;
        reporter = sender;
        pictureHash1 = firstPictureHash;
        pictureHash2 = secondPictureHash;
    }

    function addConfirmation(address sender) public{

        bool alreadyConfirmed = false;
        for (uint256 i; i < confirmations.length; i++) {
            if (confirmations[i] == sender) {
                alreadyConfirmed = true;
                break;
            }
        }

        if (!alreadyConfirmed && sender != reporter) {
            confirmations.push(sender);
        }
    }

    function getConfirmationCount() public constant returns (uint256){
        return confirmations.length;
    }

    function getId() public constant returns (uint) {
        return id;
    }

    function getReporter() public constant returns (address) {
        return reporter;
    }

    function getPictureHash1() public constant returns (bytes32) {
        return pictureHash1;
    }

    function getPictureHash2() public constant returns (bytes32) {
        return pictureHash2;
    }
}


contract Repairchain is Mortal {
    mapping (string => Report[]) reports;

    function Repairchain () {

    }

    function firstStringToBytes32(string memory source) returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function secondStringToBytes32(string memory source) returns (bytes32 result) {
        assembly {
            result := mload(add(source, 64))
        }
    }

    function bytes32ToString(bytes32 x) constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }


    function addReportToCity(string city, string pictureHash) {

        bytes32 pictureHashAsBytes32first = firstStringToBytes32(pictureHash);
        bytes32 pictureHashAsBytes32second = secondStringToBytes32(pictureHash);
        Report newReport = new Report(msg.sender, pictureHashAsBytes32first, pictureHashAsBytes32second);
        reports[city].push(newReport);
    }

    function getReporter(string city, uint id) constant returns (address) {
        return getReport(city, id).getReporter();
    }

    function getReport(string city, uint id) public constant returns (Report) {
        //iterate over Reports list and retorn Report with id == id
        return reports[city][id];
    }

    function addConfirmationToReport(string city, uint id) public {
        getReport(city, id).addConfirmation(msg.sender);
    }

    function getConfirmationCount (string city, uint id) public constant returns (uint256) {
        return getReport(city, id).getConfirmationCount();
    }

    function getPictureHash1 (string city, uint id) public constant returns (string) {
        bytes32 hash1 = getReport(city, id).getPictureHash1();
        return bytes32ToString(hash1);
    }

    function getPictureHash2 (string city, uint id) public constant returns (string) {
        bytes32 hash2 = getReport(city, id).getPictureHash2();
        return bytes32ToString(hash2);
    }



}


