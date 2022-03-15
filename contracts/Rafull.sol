//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Rafull {
  address public owner;
  uint public maxSupply;
  uint public totalSupply;
  uint256 public ticketPrice;
  uint256 public rafflePrize;
  bool public raffleCompleted = false;

  constructor(uint _maxSupply, uint256 _ticketPrice, uint256 _rafflePrize) {
    require(_rafflePrize <= _maxSupply*_ticketPrice, "Ticket earnings won't cover raffle prize");

    owner = msg.sender;
    maxSupply = _maxSupply;
    ticketPrice = _ticketPrice;
    rafflePrize = _rafflePrize;
  }

  mapping(uint => address) public raffleBoard;
  event RaffleNotification(address winner, uint256 rafflePrize, uint256 raffleDate);

  function runRaffle() public payable returns (address) {
    require(msg.sender == owner, "This function is only exposed for contract owner");
    require(!raffleCompleted, "Prize has been already sent");
    require(totalSupply > 0, "Not enough tickets sold");

    uint winnerTicket = getRandomTicket();
    address winner = raffleBoard[winnerTicket];
    
    payable(winner).transfer(rafflePrize);
    emit RaffleNotification(winner, rafflePrize, block.timestamp);

    return winner;
  }

  function getRandomTicket() public view returns (uint) {
    return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % totalSupply;
  }

  function buyTicket(uint256 amount) public payable {

    require(totalSupply < maxSupply, "Tickets sold out");
    require(amount == msg.value, "Wrong amount sent");
    require(msg.value == ticketPrice, "Wrong amount sent");

    raffleBoard[totalSupply] = msg.sender;
    totalSupply++;
  }

  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }

  function withdraw() public payable {
    require(msg.sender == owner, "This function is only exposed for contract owner");

    payable(msg.sender).transfer(payable(owner).balance);
  }

  receive() external payable {
    // this function enables the contract to receive funds
  }

}