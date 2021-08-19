pragma solidity ^0.4.25;

import "./ownable.sol";

contract ZombieFactory is Ownable {
    
    // triggered when new zombie is created 
    // will be used by front end to display zombies created
    event NewZombie(uint zombieId, string name, uint dna);

    // length of dna
    uint dnaDigits = 16;
    // used to trim the randomly generated hash to get dna uint 
    uint dnaModulus = 10 ** dnaDigits;
    // cool down period between certain function executions
    uint cooldownTime = 1 days;

    // zombie object to be created 
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }
    
    // state variable of zombies to hold all zombies created by contract
    Zombie[] public zombies;
    
    // mappings key/value pairs to map zombies to owner 
    mapping (uint => address) public zombieToOwner;
    // key/value pair for tracking zombies owned per address
    mapping (address => uint) ownerZombieCount;

    // this is a internal function used only within inherited contracts
    // it creates a zombie, storing in the array 
    // and emits a new zombie event
    function _createZombie(string _name, uint _dna) private {
        // create new zombie and push to zombie array
        // grab index and store locally
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
        // map owner to id of zombie
        zombieToOwner[id] = msg.sender;
        // increase zombie count for owner
        ownerZombieCount[msg.sender]++;
        // emit NewZombie event using id, name, dna
        emit NewZombie(id, _name, _dna);
    }

    // this is a private view only function
    // generates random dna string from input string 
    // returns a uint of 16 length for use as dna in new zombies
    function _generateRandomDna(string _str) private view returns (uint) {
        // generate a random uint by encoding the string passed in 
        // keccak256 is an encoding alg based off SHA3
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        // return rand passed through the dnaModulus which trims to 16 digits
        return rand % dnaModulus;
    }

    // this is a public function for users to create a random zombie
    // pass in a name and it calls the generateRandomDna with the name
    // this returns the dna uint which is used to create the zombie internally
    // that function emits the event to the front end
    function createRandomZombie(string _name) public {
        // require that sender has not called this before
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createZombie(_name, randDna);
    } 
    
}
