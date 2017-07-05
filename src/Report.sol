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

    function Report(address sender) {
        id = now + msg.gas;
        timeStamp = now;
        reporter = sender;
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
}


contract Repairchain is Mortal {
    mapping (string => Report[]) reports;

    function Repairchain () {

    }

    function addReportToCity(string city) {
        Report newReport = new Report(msg.sender);
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

    //function getReports(string city) constant returns (mapping(string => Report)){
    //    Report myReports = reports[city];
    //    address myName = myReport.getReporter();
     //   return myReports;
    //}


}


