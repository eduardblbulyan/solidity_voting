// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
// little voting with delegation
contract Ballot {
    // Declares a new complex type which will
    // be used for variables later
    // it will represent a single voter
    struct Voter {
        uint weight; // this is accumulated by delegation
        bool voted; // if true,that person already voted
        address delegate; // person delegated to
        uint vote; // index of the voted proposal
    }
    // This is type for single proposal
    struct Proposal {
        bytes32 name; // short name up to 32 bytes
        uint voteCount; // number of accumulated votes
    }
    
    address public chairperson;

    // Declares a state variable that 
    // stores a 'Voter' struct for each possible address

    mapping(address => Voter) public voters;
    
    // A dynamically-sized array of 'Proposal' struct
    Proposal[] public proposals;

    // creating new ballot to chhose one of 'proposalNames'
    constructor(bytes32[] memory proposalNames){
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        // For each of the provided proposal names,
        // create a new proposal object and add it
        // to the end of the array
        for (uint i=0;i<proposalNames.length; i++){
            // Proposal({...}) ` creates a temporary
            // Proposal object and 'proposal.push(...)`
            // append it to the end of 'proposals'
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }  
    }

    
}