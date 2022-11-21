// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IVoteD21 {
//define the structure inside the interface
    struct Subject{
        string name;
        int votes;
}
    function addSubject(string memory name) external;  //add a new subject into the voting system using the name
    function addVoter(address addr) external; //add a new voter into the voting system 
    function getSubjects() external view returns(address[] memory); //get addresses of all registered subjects
    function getSubject(address addr) external view returns(Subject memory); //get the subject details
    function votePositive(address addr) external; //vote positive for the subject
    function voteNegative(address addr) external; //vote negative for the subject        
    function getRemainingTime() external view returns(uint); //get the remaining time to the voting end in seconds
    function getResults() external view returns(Subject[] memory); //get the voting results, sorted descending by votes
}