// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./ownable.sol";
import "./safemath.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract ZombieFactory is Ownable, VRFConsumerbase {
    
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;
    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days;

    bytes32 public keyHash;
    uint256 public fee;
    uint256 public randomResult;

    struct Zombie {
      string name;
      uint dna;
      uint32 level;
      uint32 readyTime;
      uint16 winCount;
      uint16 lossCount;
    }

    /*
    notes:
    Chainlink VRF是区块链行业领先的安全随机数生成器（RNG），为智能合约和链下系统提供可验证且防篡改的随机数来源。 Chainlink VRF通过加密技术为开发者保障随机数的安全性和可验证性，帮助他们打造出更加开放、可访问且防篡改的系统
    creat a random to make the block chain secure
    */

    Zombie[] public zombies;
    constructor() VRFConsumerBase(
        0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B,  // VRF Coordinator
        0x01BE23585060835E02B77ef475b0Cc51aA1e0709   // LINK Token
    ) public{
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311; // this is just a test for chainlink random 
        fee = 100000000000000000;

    }
    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    function _createZombie(string memory _name, uint _dna) internal {
        uint id =  zombies.length;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
        zombies.push(Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime), 0, 0));
        
        emit NewZombie(id, _name, _dna);
    }

    function getRandomNumber() public returns (bytes32 requestId) {
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }
    // use chainlink vrf to create random zombie, so the way is out
    //function _generateRandomDna(string memory _str) private view returns (uint) {
    //    uint rand = uint(keccak256(abi.encodePacked(_str)));
    //    return rand % dnaModulus;
    // }

    function createRandomZombie(string memory _name) public {
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createZombie(_name, randDna);
    }

}
