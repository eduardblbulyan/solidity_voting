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

    // Give 'voter' the right to vote on this ballot
    // May only be called by 'chairperson'
    function giveRightToVote(address voter) external {
        // If the first argument of 'require' evaluates
        // 'false' , execution terminates and all
        // changes to the state and to ETH balances
        // are retrieved
        // As second argument we can provide explanation
        // about what went wrong
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote"
        );
        require(
            !voters[voter].voted,
            "The voter already voted"
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }
    
    // Delegate your vote to the voter `to`
    function delegate(address to) external {
        // assigns reference
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "You have no rights to vote!");
        require(!sender.voted,"You already voted");
        require(to != msg.sender, "Self-delegation is disallowed!");
        // This is very dangerous,
        // because if they run too long, they might
        // need more gas than is available in a block.
        while (voters[to].delegate != address(0)){
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop in delegation.");
        }
        Voter storage delegate_ = voters[to];
        // voters cannot delegate to acc that cannot vote
        require(delegate_.weight >= 1);

        sender.voted = true;
        sender.delegate = to;

        if (delegate_.voted){
            proposals[delegate_.vote].voteCount += sender.weight;
        }
        else{
            delegate_.weight += sender.weight;
        }
    }
    function vote(uint proposal) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += sender.weight;
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() external view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }
}