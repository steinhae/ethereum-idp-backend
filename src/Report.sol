pragma solidity ^0.4.11;


/* This contract class exists, because it should be possible to remove a deployed contract again */
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


/* Report object is used to store all information about a report*/
contract Report {

    /*hard coded number of confirmations*/
    uint constant CONFIRMATION_NUMBER = 5;

    bytes20 id;
    uint timeStamp;
    address reporter;
    address[] confirmations;
    bytes32 pictureHash1;
    bytes32 pictureHash2;
    bool enoughConfirmations;
    bytes32 longitude;
    bytes32 latitude;

    /* description cut into 4 chunks, because it is not possible to
     * transfer Dynamically-sized byte arrays (strings) between contracts*/
    bytes32 description1;
    bytes32 description2;
    bytes32 description3;
    bytes32 description4;

    bool incentivePaidToReporter;
    bool fixedReport;
    address fixReporter;
    bytes32 fixHash1;
    bytes32 fixHash2;
    address[] fixConfirmations;
    bool enoughFixConfirmations;

    /* initializes a Report with the information it needs*/
    function Report(address sender, bytes32 firstPictureHash, bytes32 secondPictureHash, bytes32 longi, bytes32 lat, bytes32 desc1, bytes32 desc2, bytes32 desc3, bytes32 desc4) {
        id = bytes20(keccak256(longi, lat, firstPictureHash, msg.sig, msg.sender, block.blockhash(block.number - 1)));
        timeStamp = now;
        reporter = sender;
        pictureHash1 = firstPictureHash;
        pictureHash2 = secondPictureHash;
        enoughConfirmations = false;
        incentivePaidToReporter = false;
        longitude = longi;
        latitude = lat;
        fixedReport = false;
        description1 = desc1;
        description2 = desc2;
        description3 = desc3;
        description4 = desc4;
    }

    /* adds confirmation to this report object.
     * checks if sender already confirmed or if sender is the reporter
     * if report has CONFIRMATION_NUMBER many confirmations after confirming
     * already confirmed flag will be set*/

    function addConfirmation(address sender) public{
        if(sender != reporter && !enoughConfirmations){
            bool alreadyConfirmed = false;
            for (uint256 i; i < confirmations.length; i++) {
                if (confirmations[i] == sender) {
                    alreadyConfirmed = true;
                    break;
                }
            }

            if (!alreadyConfirmed) {
                confirmations.push(sender);
                if (confirmations.length == CONFIRMATION_NUMBER){
                    enoughConfirmations = true;
                }
            }
        }
    }

    /*analogous to addConfirmation but only works if report is fixed*/
    function addFixConfirmation(address sender) public{
        if(sender != fixReporter && fixConfirmations.length < CONFIRMATION_NUMBER && fixedReport){
            bool alreadyConfirmed = false;
            for (uint256 i; i < fixConfirmations.length; i++) {
                if (fixConfirmations[i] == sender) {
                    alreadyConfirmed = true;
                    break;
                }
            }
            if (!alreadyConfirmed) {
                fixConfirmations.push(sender);
                if(fixConfirmations.length == CONFIRMATION_NUMBER){
                    enoughFixConfirmations = true;
                }
            }
        }
    }

	
    /*contractors can set a report to fixed with the picture of the fixed object if it has enough confirmations*/
    function reportFix(bytes32 hash1, bytes32 hash2) public {
        if(enoughConfirmations){
            fixedReport = true;
            fixHash1 = hash1;
            fixHash2 = hash2;
            fixReporter = msg.sender;
        }
    }



    function setIncentivePaidToReporter(){
        incentivePaidToReporter = true;
    }

    /*getter for attributes of report object*/

    function getIncentivePaidToReporter() public constant returns (bool) {
        return incentivePaidToReporter;
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

    function getDescription1() public constant returns (bytes32) {
        return description1;
    }

    function getDescription2() public constant returns (bytes32) {
        return description2;
    }

    function getDescription3() public constant returns (bytes32) {
        return description3;
    }

    function getDescription4() public constant returns (bytes32) {
        return description4;
    }

    function getTimestamp() public constant returns (uint) {
        return timeStamp;
    }

    function getFixedPictureHash1() public constant returns (bytes32) {
        return fixHash1;
    }

    function getFixedPictureHash2() public constant returns (bytes32) {
        return fixHash2;
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

    /* stores all the reports sorted by city */
    mapping (string => Report[]) reports;
    /* stores all the report IDs sorted by city */
    mapping (string => bytes20[]) ids;
    /* stores all the cities enabled to store reports */
    string[] cities;
    /* stores the balance of each city */
    mapping (string => uint) private balances;
	
	
	/*initializes new report object with given parameters and adds it to a city if this city exists*/
    function addReportToCity(string city, string pictureHash, string longitude, string latitude, string description) {
        bool cityExists = cityExist(city);
        if(cityExists){
			
			/* multiple variables for same attribute because it is not possible jet to pass dynamic size arrays (strings) betreen contracts*/
            bytes32 pictureHashAsBytes32first = stringToBytes32(pictureHash,1);
            bytes32 pictureHashAsBytes32second = stringToBytes32(pictureHash, 2);
            bytes32 longi = stringToBytes32(longitude, 1);
            bytes32 lati = stringToBytes32(latitude, 1);

            bytes32 desc1 = stringToBytes32(description, 1);
            bytes32 desc2 = stringToBytes32(description, 2);
            bytes32 desc3 = stringToBytes32(description, 3);
            bytes32 desc4 = stringToBytes32(description, 4);
            Report newReport = new Report(msg.sender, pictureHashAsBytes32first, pictureHashAsBytes32second, longi, lati, desc1, desc2, desc3, desc4);
            reports[city].push(newReport);
        }
    }
	
	/*checks if city exists in the contract*/
    function cityExist(string city) private returns (bool){
        bool cityExists = false;
        for (uint256 i; i < cities.length; i++) {
            if (equal(cities[i], city)) {
                cityExists = true;
                break;
            }
        }
        return cityExists;
    }
	
	function addCity (string city) payable public {
        cities.push(city);
        balances[city] += msg.value;
    }

    /* if city exists in the system it can add fonds this way*/
    function addFundsToCity(string city) payable public {
        if (cityExist(city)) {
            balances[city] += msg.value;
        }
    }

    function getCityBalance(string city) constant returns (uint) {
        return balances[city];
    }

    /*wrapper for addConfirmation function of Report identified by city and id*/
    function addConfirmationToReport(string city, bytes20 id) public {
        getReport(city, id).addConfirmation(msg.sender);
    }
	
	/*wrapper for addFixConfirmation function of Report identified by city and id */
    function addFixConfirmationToReport(string city, bytes20 id) public {
        Report report = getReport(city, id);
        report.addFixConfirmation(msg.sender);
        // pay incentive to reporter
        if (report.getEnoughFixConfirmations() && !report.getIncentivePaidToReporter() && balances[city] > 5 finney) {
            report.setIncentivePaidToReporter();
            balances[city] -= 5 finney;
            report.getReporter().transfer(5 finney);
        }
    }

    /*wrapper for reportFix function of Report Class*/
    function reportFix (string city, bytes20 id, string pictureHash) public {
        bytes32 pictureHashAsBytes32first = stringToBytes32(pictureHash, 1);
        bytes32 pictureHashAsBytes32second = stringToBytes32(pictureHash, 2);
        getReport(city, id).reportFix(pictureHashAsBytes32first, pictureHashAsBytes32second);
    }

	

    /*returns report identified with city and id*/
    function getReport(string city, bytes20 id) private constant returns (Report) {
        //iterate over Reports list and return Report with id == id
        Report[] storage cityReports = reports[city];
        for (uint i = 0; i < cityReports.length; i++) {
            if(cityReports[i].getId() == id){
                return cityReports[i];
            }
        }
    }

    /*simple getter wrapper functions*/

    function getReporter(string city, bytes20 id) constant returns (address) {
        return getReport(city, id).getReporter();
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
        bytes32 hash = getReport(city, id).getPictureHash1();
        return bytes32ToString(hash);
    }

    function getPictureHash2 (string city, bytes20 id) public constant returns (string) {
        bytes32 hash = getReport(city, id).getPictureHash2();
        return bytes32ToString(hash);
    }

    function getDescription1 (string city, bytes20 id) public constant returns (string) {
        bytes32 hash = getReport(city, id).getDescription1();
        return bytes32ToString(hash);
    }

    function getDescription2 (string city, bytes20 id) public constant returns (string) {
        bytes32 hash = getReport(city, id).getDescription2();
        return bytes32ToString(hash);
    }

    function getDescription3 (string city, bytes20 id) public constant returns (string) {
        bytes32 hash = getReport(city, id).getDescription3();
        return bytes32ToString(hash);
    }

    function getDescription4 (string city, bytes20 id) public constant returns (string) {
        bytes32 hash = getReport(city, id).getDescription4();
        return bytes32ToString(hash);
    }

    function getTimestamp(string city, bytes20 id) public constant returns (uint) {
        return getReport(city, id).getTimestamp();
    }

    function getFixedPictureHash1 (string city, bytes20 id) public constant returns (string) {
        bytes32 hash = getReport(city, id).getFixedPictureHash1();
        return bytes32ToString(hash);
    }

    function getFixedPictureHash2 (string city, bytes20 id) public constant returns (string) {
        bytes32 hash = getReport(city, id).getFixedPictureHash2();
        return bytes32ToString(hash);
    }

    function getReportsLengthOfCity (string city) public constant returns (uint) {
        return reports[city].length;
    }

    function getReportIdsFromCity (string city) constant returns (bytes20[]) {
        Report[] storage cityReports = reports[city];
        for (uint i = 0; i < cityReports.length; i++) {
            ids[city].push(cityReports[i].getId());
        }
        return ids[city];
    }

    function getFixConfirmationCount (string city, bytes20 id) public constant returns (uint256) {
        return getReport(city, id).getFixConfirmationCount();
    }

    function getEnoughFixConfirmations(string city, bytes20 id) public constant returns (bool){
        return getReport(city, id).getEnoughFixConfirmations();
    }

    function getFixedReport(string city, bytes20 id) public constant returns (bool) {
        return getReport(city, id).getFixedReport();
    }	
	
	
	/*======Helpers Functons========*/

    function stringToBytes32(string memory source, uint start) private returns (bytes32 result) {
        uint startIndex = 32*start;
        assembly {
            result := mload(add(source, startIndex))
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

    

    function compare(string _a, string _b) private returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
            if (a.length < b.length)
                return -1;
            else if (a.length > b.length)
                return 1;
            else
                return 0;
    }

    function equal(string _a, string _b) private returns (bool) {
        return compare(_a, _b) == 0;
    }

}


