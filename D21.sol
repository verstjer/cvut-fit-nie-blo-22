// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
import "./IVoteD21.sol";

contract D21 is IVoteD21 {

    // Attributes
    mapping(address => Subject) private subjects; // wordt subjects
    address[] private subjectAddressList; // wordt subjectAddressList
    mapping(address => Voter) private voters; // wordt voters
    address private owner;
    uint private votingDeadline;

    // Voter structure
    struct Voter{   
        int8 positive_votes;
        int8 negative_votes;
        int8 flag;
        address[] voted;
    }


    constructor() {
        votingDeadline = block.timestamp + 604800; //604800 = 7 days  
        owner = msg.sender;
    } 

    // Modifier to check if there is still time left
    modifier inTime() {
        require(block.timestamp < votingDeadline , "Voting time window is ended.");
        _;
    }

    // Function for adding a new subject
    function addSubject(string memory name) external inTime() {
        // We check if sender has already added a subject
        require(keccak256(abi.encodePacked(subjects[msg.sender].name)) == keccak256(abi.encodePacked("")), "You've already added a subject. ");
        // We check if the name is not an empty string
        require(keccak256(abi.encodePacked(name)) != keccak256(abi.encodePacked("")), "The name is empty.");
        subjects[msg.sender] = Subject(name,0); // We put the subject in the mapping
        subjectAddressList.push(msg.sender); // We add the key of the subject to the list
    }

    // Function for adding a new voter
    function addVoter(address addr) external inTime() {
        require(msg.sender == owner , "Only the owner can add eligible voters"); // Check if owner adds the new voter
        require(voters[addr].flag < 1, "Voter already added"); // Check if voter address is already registered  
        address[] memory votedOn; // create new dynamic array of addresses in memory
        voters[addr] = Voter(2,1,1,votedOn); // We put the voter in the mapping   
    }

    // Get subjects addresses
    function getSubjects() external view returns(address[] memory) {
    return subjectAddressList;
    }

    // Get subject
    function getSubject(address addr) external view returns(Subject memory) {
        require(keccak256(abi.encodePacked(subjects[addr].name)) != keccak256(abi.encodePacked("")), "Subject not found."); // Check if subject with given address exists
        return subjects[addr]; 
    }

    // Function for positive votes
    function votePositive(address addr) external inTime() {
      require((voters[msg.sender].positive_votes > 0) , "Your positive votes are finished."); // Check if positive votes left
      require(checkIfAlreadyVoted(addr, voters[msg.sender].voted)==false, "Voter has already voted on this subject. "); // Check if subject already received a vote from voter
        subjects[addr].votes += 1;
        
        voters[msg.sender].positive_votes -= 1;

        voters[msg.sender].voted.push(addr); // Put subject address in list votes of voter

   

    }

    // Function for negative votes
    function voteNegative(address addr) external inTime() {    
        require(voters[msg.sender].positive_votes == 0, "You first need to use all your positive votes."); // Check if all positive votes are used
        require(voters[msg.sender].negative_votes == 1, "Your votes are finished. "); // Check if voter still has a negative vote
        require(checkIfAlreadyVoted(addr, voters[msg.sender].voted)==false, "Voter has already voted on this subject. "); // Check if subject already received a vote from voter
        subjects[addr].votes -= 1;
        voters[msg.sender].negative_votes = 0; 
        voters[msg.sender].voted.push(addr); // Put subject address in list votes of voter

    }   

    function getRemainingTime() external view returns(uint) {
        if(votingDeadline > block.timestamp) {
            return votingDeadline - block.timestamp;
        }
        else {
            return 0;
        }

    }

    function getResults() external view returns(Subject[] memory) {
        uint  length = subjectAddressList.length; 
        require(subjectAddressList.length > 0 , "No subjects registered yet."); // Check if address list is not empty
        Subject[] memory subjectList = new Subject[](length); // Make a new list of subjects inside function
        for (uint i=0; i < length ; i++) {
            Subject memory sub = subjects[subjectAddressList[i]]; // Get subject out of subjects mapping and assign to temporal variable
            subjectList[i] = sub; // Put subject into the list
        }
        return sort(subjectList); // sort the list descending by votes and return
        
    }


    // Function to check if voter has already voted for subject
    function checkIfAlreadyVoted(address addr,address[] storage list) view private returns(bool response) {
        response = false;
        for(uint i = 0; i < list.length; i++) {
            if(addr == list[i]) {
                response = true;
            }
        }
        return response;
    }
    
    // Quicksort descending function from stackoverflow, adapted to use case
    function quickSort(Subject[] memory arr, int left, int right) internal view {
    int i = left; // smallest index
    int j = right; // largest index
    if (i == j) return; // if left and right are the same, stop function
    int pivot = arr[uint(left + (right - left) / 2)].votes; // calculate pivot point of votes, we use int and not uint because pivot point could be negative
    while (i <= j) {
        while (arr[uint(i)].votes < pivot) i++; // as long as number of votes is smaller than pivot, add 1 to counter i
        while (pivot < arr[uint(j)].votes) j--; // as long as number of votes is larger than pivot, deduct 1 of counter j
        if (i <= j) {
            // We will switch subjects' places 
            (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
            Subject memory tempPlaceSubject; // temporal variable to switch subjects' places
            tempPlaceSubject = arr[uint(i)]; // temporal store left one
            arr[uint(i)] = arr[uint(j)]; // left one becomes right one
            arr[uint(j)] = tempPlaceSubject; // right one becomes left one with aid of temporal storage
            i++;
            j--;
        }
    }
    if (left < j) // if input left is smaller than index right, run function again
        quickSort(arr, left, j);
    if (i < right) // if input right is larger than index left, run function again
        quickSort(arr, i, right);
}
    // Because the quickSort return type is void (it only modifies the array), we still need another function to return the list of subjects
    function sort(Subject[] memory arr) internal view returns (Subject[] memory) {
        quickSort(arr,int(0), int(arr.length - 1));
        return arr;
    }

}