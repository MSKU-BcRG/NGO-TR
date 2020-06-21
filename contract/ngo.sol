pragma solidity >=0.4.22 <0.6.0;
pragma experimental ABIEncoderV2;

contract ngo {
    struct Participant{
        int rewards;
        bytes32 credentialHash;
    }

    struct Activity{
        string eventName;
        string place;
        string eventType;
        string dateTime;
        string [] needs;
        int [] needRewards;
        bytes32[]  participantCredentialHashes;
        string responsiblePerson;
        string[] participantsWithTaskID;
        
    }
    function stringToBytes32(string memory source) private returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
    function bytes32ToString (bytes32 data)private returns (string memory) {
        bytes memory bytesString = new bytes(32);
        for (uint j=0; j<32; j++) {
            byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[j] = char;
            }
        }
        return string(bytesString);
    }
    mapping(uint256 => Activity) public activities;
    mapping(uint256 => Participant) public participants;
    int[] activityIndexes;
    int activityAmount=0;
    uint256 participantAmount=0;
    function createParticipant(int rewardAmount, bytes32 prtCredentHash)public{
        Participant memory prt;
        prt.rewards=rewardAmount;
        prt.credentialHash=prtCredentHash;
        participants[participantAmount]=prt;
        participantAmount++;
    }
    function createEvent(uint256 eventID, string memory eName,string memory eplace,string[] memory eneeds,
    string memory eType,string memory eTime,string memory eresponsiblePerson,int256 []memory rewardsOfNeeds)public{
        Activity memory act;
        act.eventName=eName;
        act.place=eplace;
        act.eventType=eType;
        act.dateTime=eTime;
        act.responsiblePerson=eresponsiblePerson;
        uint256 needsLength = eneeds.length-1;
        for(uint i= 0; i<needsLength; i++){
            act.needs[i]=eneeds[i];
            act.needRewards[i]=rewardsOfNeeds[i];
        }
        activities[eventID]=act;
        activityIndexes.push(activityAmount);
        activityAmount++;
    }
    
    
    
    
    function assignVolunteer(string memory volunteerIDHash,string memory task, uint256  eventID) public returns(bool){
        Activity storage act=activities[eventID];
        uint256 taskID;
        act.participantCredentialHashes.push(stringToBytes32(volunteerIDHash));
        uint needsLength=activities[eventID].needs.length;
        for(uint16 i=0; i<needsLength; i++){
            
            if(keccak256(abi.encode(task)) == keccak256(abi.encode(activities[eventID].needs[i])))
                taskID=i;
        }
        act.participantsWithTaskID.push(volunteerIDHash);
        act.participantsWithTaskID.push(bytes32ToString(bytes32(taskID)));
        return true;
    }
    
    function giveReward(string memory responsiblePerson, string memory volunteerIDHash, uint256 eventID,int  reward )public returns(bool){
        Activity storage act = activities[eventID];
        if(keccak256(abi.encode(responsiblePerson))==keccak256(abi.encode(act.responsiblePerson))){
            for(uint16 i=0; i<act.participantCredentialHashes.length-1; i++){
                if(keccak256(abi.encode(volunteerIDHash))==keccak256(abi.encode(act.participantCredentialHashes[i]))){
                    participants[i].rewards= participants[i].rewards+reward;
                }
            }
        }
    }

    
    function giveFeedBack(uint256 eventID,string memory message, string memory volunteerIDHash)public returns(bytes32,bytes32) {
         Activity memory act=activities[eventID];
         for(uint16 i=0; i<act.participantCredentialHashes.length-1; i++){
                if(keccak256(abi.encode(volunteerIDHash))==keccak256(abi.encode(act.participantCredentialHashes[i]))){
                            bytes32 a=stringToBytes32(message);
                            bytes32 b=stringToBytes32(volunteerIDHash);
                            return (a,b);
                }else{
                    bytes32 a=stringToBytes32("hata!");
                    bytes32 b=stringToBytes32("etkinlikte gönüllü bulunamadı!");
                    return(a,b);
                }
            }

        
    }


    //for getAllActivities, activityIndexes will be iterated as eventID's in activities from web3 side.
}
