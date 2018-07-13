
pragma solidity ^0.4.18;
// We have to specify what version of compiler this code will compile with

contract Voting {
  /* mapping field below is equivalent to an associative array or hash.
  The key of the mapping is option name stored as type bytes32 and value is
  an unsigned integer to store the vote count
  */

  mapping (bytes32 => uint8) public votesReceived;
  mapping (bytes32 => bytes32) public votingHistory;


  /* Solidity doesn't let you pass in an array of strings in the constructor (yet).
  We will use an array of bytes32 instead to store the list of options
  */

  bytes32 votingTopic;
  bytes32[] public votingOptions;


  function Voting(bytes32[] votingOptionsForMeeting) public {
    votingOptions = votingOptionsForMeeting;
  }


  function getVotingOptions() view public returns (bytes32[]) {
    return votingOptions;
  }

  // This function returns the total votes a option has received so far
  function totalVotesFor(bytes32 option) view public returns (uint8) {
    require(validVotingOption(option));
    return votesReceived[option];
  }

  // This function increments the vote count for the specified option. This
  // is equivalent to casting a vote
  function voteForOption(bytes32 option, bytes32 votingKey) public {
    require(validVotingOption(option));
    votesReceived[option] += 1;
    votingHistory[votingKey] = option;

  }

  function validVotingOption(bytes32 option) view public returns (bool) {
    for(uint i = 0; i < votingOptions.length; i++) {
      if (votingOptions[i] == option) {
        return true;
      }
    }
    return false;
  }
}
