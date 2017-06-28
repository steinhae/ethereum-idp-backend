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
    string name;
    address reporter;
    address[] confirmations;

    function Report() {
        id = msg.gas;
        timeStamp = now;
        name = "first report";
        reporter = msg.sender;
    }

    function addConfirmation() {
        if(msg.sender != reporter) {
            confirmations.push(msg.sender);
        }
    }

    function getName() public returns (string) {
        return name;
    }
}


contract Repairchain is Mortal {
    mapping(address => Report) public reports;

    function Repairchain () {
        reports[msg.sender] = new Report();
    }

    function getName() returns (string){
        Report myReport = reports[msg.sender];
        string myName = myReport.getName();
        return myName;
    }


}


