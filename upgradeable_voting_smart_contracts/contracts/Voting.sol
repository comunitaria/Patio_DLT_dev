pragma solidity ^0.4.0;

contract Voting {

    struct Vote {
        bytes32 votingName;
        bytes32[] votingOptions;
        bytes32[] userKeysUsedForVoting;
        mapping(bytes32 => uint8) votesReceivedPerOption;
        mapping (bytes32 => bytes32) userKeyVotingHistoryLog;
        bool isValue;

    }

    mapping (bytes32 => Vote) votingRegistry; // this is the registry where the results of all the votes are saved
    // mapped by the name of the voting

    function Voting(){

    }


    function submitNewVoting(bytes32[] votingOptionsForTopic, uint8[] votesReceivedForTopic,
        bytes32[] userKeysForOptions, bytes32[] votedOptionsForUserKeys, bytes32 votingNameForTopic) public {


        require(votingOptionsForTopic.length == votesReceivedForTopic.length);
        require(userKeysForOptions.length == votedOptionsForUserKeys.length);
        var newVote = votingRegistry[votingNameForTopic];
        uint votingOptionsForTopicLength = votingOptionsForTopic.length;
        for (uint i=0; i<votingOptionsForTopicLength; i++) {
            newVote.votesReceivedPerOption[votingOptionsForTopic[i]] = votesReceivedForTopic[i];
        }
        uint votedOptionsForUserKeysLength = votedOptionsForUserKeys.length;
        for (uint v=0; v<votedOptionsForUserKeysLength; v++){
            newVote.userKeyVotingHistoryLog[userKeysForOptions[v]] = votedOptionsForUserKeys[v];
        }
        newVote.votingOptions = votingOptionsForTopic;
        newVote.userKeysUsedForVoting = userKeysForOptions;
        newVote.votingName = votingNameForTopic;
        newVote.isValue = true;

        votingRegistry[votingNameForTopic] = newVote;

    }

}
