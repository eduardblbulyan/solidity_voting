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
    
    address public chainperson;

    // Declares a state variable that 
    // stores a 'Voter' struct for each possible address

    mapping(address => Voter) public voters;
    
    // A dynamically-sized array of 'Proposal' struct
    Proposal[] public proposals;
}