pragma solidity ^0.4.0;
//import "zos-lib/contracts/Initializable.sol";
contract Voting{ //is Initializable{

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
    bytes32[] votingNames;

    function initialize(){

    }


    function submitNewVoting(bytes32[] votingOptionsForTopic, uint8[] votesReceivedForTopic,
        bytes32[] userKeysForOptions, bytes32[] votedOptionsForUserKeys, bytes32 votingNameForTopic) public {
        Vote storage newVote; // memory would be better here but it is impossible due to evm restrictions:
        // https://ethereum.stackexchange.com/questions/36365/member-x-is-not-available-in-struct-y-memory-outside-of-storage

        require(votingOptionsForTopic.length == votesReceivedForTopic.length);
        require(userKeysForOptions.length == votedOptionsForUserKeys.length);
        votingNames.push(votingNameForTopic);
        newVote = votingRegistry[votingNameForTopic];
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
    function validUserKey(bytes32 userKey, bytes32 votingName) view public returns (bool) {
        if(!votingRegistry[votingName].isValue){
            return false;
        }
        bytes32[] memory votingToAnalyzeUserKeysUsedForVotings = votingRegistry[votingName].userKeysUsedForVoting;
        for (uint i = 0; i < votingToAnalyzeUserKeysUsedForVotings.length; i++) {
            if (votingToAnalyzeUserKeysUsedForVotings[i] == userKey) {
                return true;
            }
        }
        return false;
    }


    function getVotedOptionForUserKeyForVoting(bytes32 userKey, bytes32 votingName) view public returns (bytes32){
        require(votingRegistry[votingName].isValue);
        require(validUserKey(userKey, votingName));

        return votingRegistry[votingName].userKeyVotingHistoryLog[userKey];
    }

    function getNumberOfSubmittedVotings() view public returns (uint256){
        return votingNames.length;
    }

    function getVotingNameAtIndex(uint32 index) view public returns (bytes32){
        return votingNames[index];
    }

    function getRegistryIndexForVotingName(bytes32 votingName) view public returns(uint256){
        var foundIndex = false;
        for(uint i=0;i<votingNames.length;i++){
            if(votingNames[i] == votingName){
                foundIndex = false;
                return i;
            }
        }
        require(foundIndex);
    }

    function getUserKeyForVotingNameAtIndex(bytes32 votingName, uint32 index) view public returns (bytes32){

        return votingRegistry[votingName].userKeysUsedForVoting[index];
    }

    function getFullAmountOfVotesForOptionForVoting(bytes32 votingName, bytes32 votedOption) view public returns (uint256){
        return votingRegistry[votingName].votesReceivedPerOption[votedOption];
    }

}
