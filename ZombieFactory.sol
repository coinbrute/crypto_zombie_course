pragma solidity ^0.4.25;

contract ZombieFactory {
    
    // triggered when new zombie is created 
    // will be used by front end to display zombies created
    event NewZombie(uint zombieId, string name, uint dna);

    // length of dna
    uint dnaDigits = 16;
    // used to trim the randomly generated hash to get dna uint 
    uint dnaModulus = 10 ** dnaDigits;

    // zombie object to be created 
    struct Zombie {
        string name;
        uint dna;
    }
    
    // state variable of zombies to hold all zombies created by contract
    Zombie[] public zombies;

    // this is a private function used only within the contract 
    // it creates a zombie, storing in the array 
    // and emits a new zombie event
    function _createZombie(string _name, uint _dna) private {
        // create new zombie and push to zombie array
        // grab index and store locally
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
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
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    } 
    
}