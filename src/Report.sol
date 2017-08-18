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

    bytes20 id;
    uint timeStamp;
    address reporter;
    address[] confirmations;
    bytes32 pictureHash1;
    bytes32 pictureHash2;
    bool enoughConfirmations;
    bytes32 longitude;
    bytes32 latitude;

    bool fixedReport;
    address fixReporter;
    bytes32 fixHash1;
    bytes32 fixHash2;
    address[] fixConfirmations;
    bool enoughFixConfirmations;


    function Report(address sender, bytes32 firstPictureHash, bytes32 secondPictureHash, bytes32 longi, bytes32 lat) {
        id = bytes20(keccak256(longi, lat, firstPictureHash, msg.sig, msg.sender, block.blockhash(block.number - 1)));
        timeStamp = now;
        reporter = sender;
        pictureHash1 = firstPictureHash;
        pictureHash2 = secondPictureHash;
        enoughConfirmations = false;
        longitude = longi;
        latitude = lat;
        fixedReport = false;
    }

    function addConfirmation(address sender) public{
        if(sender != reporter && confirmations.length < 5){
            bool alreadyConfirmed = false;
            for (uint256 i; i < confirmations.length; i++) {
                if (confirmations[i] == sender) {
                    alreadyConfirmed = true;
                    break;
                }
            }

            if (!alreadyConfirmed) {
                confirmations.push(sender);
                /* hardcoded limit of confirmations is 5*/
                if(confirmations.length == 5){
                    enoughConfirmations = true;
                }
            }
        }
    }

    function getEnoughConfirmations() public constant returns (bool){
        return enoughConfirmations;
    }

    function getConfirmationCount() public constant returns (uint256){
        return confirmations.length;
    }

    function getId() public constant returns (bytes20) {
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

    function getLongitude() public constant returns (bytes32) {
        return longitude;
    }

    function getLatitude() public constant returns (bytes32) {
        return latitude;
    }

    function reportFix(bytes32 hash1, bytes32 hash2) public {
        if(enoughConfirmations){
            fixedReport = true;
            fixHash1 = hash1;
            fixHash2 = hash2;
            fixReporter = msg.sender;
        }
    }

    function getFixedPictureHash1() public constant returns (bytes32) {
        return fixHash1;
    }

    function getFixedPictureHash2() public constant returns (bytes32) {
        return fixHash2;
    }

    function addFixConfirmation(address sender) public{
        if(sender != fixReporter && fixConfirmations.length < 5 && fixedReport){}
            bool alreadyConfirmed = false;
            for (uint256 i; i < fixConfirmations.length; i++) {
                if (fixConfirmations[i] == sender) {
                    alreadyConfirmed = true;
                    break;
                }
            }
            if (!alreadyConfirmed) {
                fixConfirmations.push(sender);
                /* hardcoded limit of confirmations is 5*/
                if(fixConfirmations.length == 5){
                    enoughFixConfirmations = true;
                }
            }
        }
    }

    function getEnoughFixConfirmations() public constant returns (bool){
        return enoughFixConfirmations;
    }

    function getFixConfirmationCount() public constant returns (uint256){
        return fixConfirmations.length;
    }

    function getFixedReport() public constant returns (bool){
        return fixedReport;
    }
}


contract Repairchain is Mortal {
    mapping (string => Report[]) reports;

    function Repairchain () {

    }

    function firstStringToBytes32(string memory source) private returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function secondStringToBytes32(string memory source) private returns (bytes32 result) {
        assembly {
            result := mload(add(source, 64))
        }
    }

    function bytes32ToString(bytes32 x) private constant returns (string) {
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


    function addReportToCity(string city, string pictureHash, string longitude, string latitude) {
        bytes32 pictureHashAsBytes32first = firstStringToBytes32(pictureHash);
        bytes32 pictureHashAsBytes32second = secondStringToBytes32(pictureHash);
        bytes32 longi = firstStringToBytes32(longitude);
        bytes32 lati = firstStringToBytes32(latitude);
        Report newReport = new Report(msg.sender, pictureHashAsBytes32first, pictureHashAsBytes32second, longi, lati);
        reports[city].push(newReport);
    }

    function getReporter(string city, bytes20 id) constant returns (address) {
        return getReport(city, id).getReporter();
    }

    function getReport(string city, bytes20 id) public constant returns (Report) {
        //iterate over Reports list and return Report with id == id
        Report[] storage cityReports = reports[city];
        for (uint i = 0; i < cityReports.length; i++) {
            if(cityReports[i].getId() == id){
                return cityReports[i];
            }
        }
    }

    //returns true if the confirmation was added and false if already enough confirmations exist
    function addConfirmationToReport(string city, bytes20 id) public {
        getReport(city, id).addConfirmation(msg.sender);
    }

    function getConfirmationCount (string city, bytes20 id) public constant returns (uint256) {
        return getReport(city, id).getConfirmationCount();
    }

    function getEnoughConfirmations(string city, bytes20 id) public constant returns (bool){
        return getReport(city, id).getEnoughConfirmations();
    }

    function getLongitude(string city, bytes20 id) public constant returns (string) {
        bytes32 longi = getReport(city, id).getLongitude();
        return bytes32ToString(longi);
    }

    function getLatitude(string city, bytes20 id) public constant returns (string) {
        bytes32 lat = getReport(city, id).getLatitude();
        return bytes32ToString(lat);
    }

    function getPictureHash1 (string city, bytes20 id) public constant returns (string) {
        bytes32 hash1 = getReport(city, id).getPictureHash1();
        return bytes32ToString(hash1);
    }

    function getPictureHash2 (string city, bytes20 id) public constant returns (string) {
        bytes32 hash2 = getReport(city, id).getPictureHash2();
        return bytes32ToString(hash2);
    }

    function getFixedPictureHash1 (string city, bytes20 id) public constant returns (string) {
        bytes32 hash1 = getReport(city, id).getFixedPictureHash1();
        return bytes32ToString(hash1);
    }

    function getFixedPictureHash2 (string city, bytes20 id) public constant returns (string) {
        bytes32 hash2 = getReport(city, id).getFixedPictureHash2();
        return bytes32ToString(hash2);
    }

    function getReportsLengthOfCity (string city) public constant returns (uint) {
        return reports[city].length;
    }


    function getReportIdsFromCity (string city, uint start) constant returns (bytes20[100]) {
        Report[] storage cityReports = reports[city];
        bytes20[100] memory ids;
        uint end = 100*start +100;
        for (uint i = start*100; i < cityReports.length && i < end; i++) {
            ids[i] = cityReports[i].getId();
        }
        return ids;
    }

    function reportFix (string city, bytes20 id, string pictureHash) public {
        bytes32 pictureHashAsBytes32first = firstStringToBytes32(pictureHash);
        bytes32 pictureHashAsBytes32second = secondStringToBytes32(pictureHash);
        getReport(city, id).reportFix(pictureHashAsBytes32first, pictureHashAsBytes32second);
    }

    function getFixConfirmationCount (string city, bytes20 id) public constant returns (uint256) {
        return getReport(city, id).getFixConfirmationCount();
    }

    function getEnoughFixConfirmations(string city, bytes20 id) public constant returns (bool){
        return getReport(city, id).getEnoughFixConfirmations();
    }

    function addFixConfirmationToReport(string city, bytes20 id) public {
        getReport(city, id).addFixConfirmation(msg.sender);
    }

    function getFixedReport(string city, bytes20 id) public constant returns (bool) {
        return getReport(city, id).getFixedReport();
    }
}


