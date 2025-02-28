// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./errors/Errors.sol";
import "./events/Events.sol";

contract CoinToss is Ownable {
    enum PlayerChoice {
        NONE,
        HEADS,
        TAILS
    }

    enum PoolStatus {
        OPENED,
        ACTIVE,
        CLOSED
    }

    struct Player {
        address playerAddress;
        PlayerChoice choice;
        bool isEliminated;
        bool hasClaimed;
    }

    struct Pool {
        uint entryFee;
        uint maxParticipants;
        uint currentParticipants;
        uint prizePool;
        PoolStatus status;
        mapping(address => Player) players;
        uint currentRound;
        address[] playersInPool;
        mapping(uint => mapping(address => bool)) roundParticipation;
        mapping(uint => mapping(address => Choice)) roundSelection;
        mapping(uint => uint) headsCount;
        mapping(uint => uint) tailsCount;
        mapping(uint256 => bool) roundCompleted;
    }

    uint poolCount;
    mapping(uint => Pool) pools;
   
    

    modifier poolExists(uint _poolId) {
        require(_poolId < poolCount, "Pool does not exist");
        _;
    }

    constructor() Ownable(msg.sender){
        poolCount = 0;
    }

    function createPool(uint _entryFee, uint _maxParticipants) external onlyOwner {
        if(_entryFee == 0){
            revert Errors.EntryFeeMustBeGreaterThanZero();
        }
        
        uint poolId = poolCount++;
        
        Pool storage newPool = pools[poolId];
        newPool.entryFee = _entryFee;
        newPool.maxParticipants = _maxParticipants;
        newPool.currentParticipants = 0;
        newPool.prizePool = 0;
        newPool.status = PoolStatus.OPENED;
        newPool.currentRound = 1;
        
        emit Events.PoolCreated(poolId, _entryFee, _maxParticipants);
    }

    function joinPool(uint _poolId) external payable poolExists(_poolId){
        Pool storage pool = pools[_poolId];
        require(pool.status == PoolStatus.OPENED, "The Pool is not yet opened for participation");
        require(msg.value == pool.entryFee, "Entry fee is not met");
        require(pool.currentParticipants < pool.maxParticipants, "The pool is already full");
        require(pool.players[msg.sender].playerAddress == address(0), "Player has already joined this pool");

        Player storage newPlayer = pool.players[msg.sender];
        newPlayer.playerAddress = msg.sender;
        
        pool.prizePool += msg.value;
        pool.currentParticipants++;
        pool.playersInPool.push(msg.sender);
        newPlayer.choice = PlayerChoice.NONE;
        newPlayer.isEliminated = false;
        newPlayer.hasClaimed = false;

        if (pool.currentParticipants == pool.maxParticipants) {
            pool.status = PoolStatus.ACTIVE;
        }

        emit Events.PlayerJoined(_poolId, newPlayer.playerAddress);
    }

    function makeSelection(uint _poolId, PlayerChoice _choice) external poolExists(_poolId){
        Pool storage pool = pools[_poolId];
        Player storage player = pool.players[msg.sender];

        require(pool.status == PoolStatus.ACTIVE, "Pool has to be active");
        require(!player.isEliminated, "Player is eliminated");
        require(!pool.roundParticipation[pool.currentRound][msg.sender], "Already made a selection for this round");

        pool.roundParticipation[pool.currentRound][msg.sender] == true;
        pool.roundSelection[pool.currentRound][msg.sender] = _choice; 

        if (_choice == Choice.HEADS) {
            pool.headsCount[pool.currentRound]++;
        } 
        if {
            pool.tailsCount[pool.currentRound]++;
        }
    }

    

}
