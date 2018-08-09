pragma solidity ^0.4.0;

contract Voting {
    // solidity cannot save a dictionary directly in the constructor this is why we have to create it
    // with the help of 2 arrays
    bytes32[] public votingOptions;
    uint8[] public votesReceived;
    bytes32[] public userKeysUsedForVoting;
    mapping (bytes32 => uint8) public votesReceivedPerOption;
    mapping (bytes32 => bytes32) public userKeyVotingHistoryLog;

    bytes32 public votingName;

    function Voting(bytes32[] votingOptionsForTopic, uint8[] votesReceivedForTopic,
        bytes32[] userKeysForOptions, bytes32[] votedOptionsForUserKeys, bytes32 votingNameForTopic) public {
        votingOptions = votingOptionsForTopic;
        votesReceived = votesReceivedForTopic;
        userKeysUsedForVoting = userKeysForOptions;

        require(votingOptionsForTopic.length == votesReceivedForTopic.length);
        uint votingOptionsForTopicLength = votingOptionsForTopic.length;
        for (uint i=0; i<votingOptionsForTopicLength; i++) {
            votesReceivedPerOption[votingOptionsForTopic[i]] = votesReceivedForTopic[i];
        }

        require(userKeysForOptions.length == votedOptionsForUserKeys.length);
        uint votedOptionsForUserKeysLength = votedOptionsForUserKeys.length;
        for (uint v=0; i<votedOptionsForUserKeysLength; v++){
            userKeyVotingHistoryLog[userKeysForOptions[v]] = votedOptionsForUserKeys[v];

        }

        votingName = votingNameForTopic;
    }

    //  note: the most convenient thing would be to return the whole votes and voting history mapping.
    //  there is a limitation in the ethereum evm that does not allow us to do this.
    //  At the moment there's no way to enumerate the elements in a mapping. In order to know what to return,
    //  Solidity would need to keep track of all of the keys that have been used, which it does not do
    //  because of this we can only return the votes one by one by accessing the mapping directly
    function getFullAmountOfVotesForOption(bytes32 option) view public returns (uint8){
        require(validVotingOption(option));
        return votesReceivedPerOption[option];
    }
    function getVotedOptionForUserKey(bytes32 userKey) view public returns (bytes32){
        require(validUserKey(userKey));
        return userKeyVotingHistoryLog[userKey];
    }


    function validVotingOption(bytes32 option) view public returns (bool) {
        for (uint i = 0; i < votingOptions.length; i++) {
            if (votingOptions[i] == option) {
                return true;
            }
        }
        return false;
    }

    function validUserKey(bytes32 userKey) view public returns (bool) {
        for (uint i = 0; i < userKeysUsedForVoting.length; i++) {
            if (userKeysUsedForVoting[i] == userKey) {
                return true;
            }
        }
        return false;
    }



    function setVotingName(bytes32 newVotingName) public {
        votingName = newVotingName;
    }

    function getVotingName() view public returns (bytes32) {
        return votingName;
    }
}
