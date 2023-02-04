// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
  uint256 public deadline = block.timestamp +  72 hours;
  uint256 public constant threshold = 1 ether;
  bool openForWithdraw = false;
  modifier notCompleted {
    require(!exampleExternalContract.completed(), "Contract already completed");
    _;
  }

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
      
      
  }

  mapping(address => uint256) public balances;
  event Stake(address,uint256);
  


 

  function stake() public payable {
    require(msg.value > 0, "You need to send some ether");
    require(block.timestamp <= deadline , "you can't stake as deadline has passed");
    balances[msg.sender] += msg.value;

     emit Stake(msg.sender,msg.value);
    
 
  }

  function execute() public notCompleted {
     
    require(block.timestamp >= deadline ,"deadline has not yet passed");
    
    
    if(address(this).balance<threshold)
     {
      openForWithdraw = true;

     }
     else
     {
       exampleExternalContract.complete{value: address(this).balance}();
     }

  }
  function withdraw() public notCompleted
{

     
     
    require(openForWithdraw == true, "you can't withdraw yet!");

    require(address(this).balance < threshold && block.timestamp >= deadline , "you can't withdraw yet!");
    
    uint amount = balances[msg.sender];
  
    balances[msg.sender] = 0;
    payable(msg.sender).transfer(amount);
   

}
  function timeLeft() public view returns(uint256) {
   if(block.timestamp>=deadline)
      {
          return 0;
      }
      else
     {
          return deadline - block.timestamp; 

      }
  }

  receive() external payable {
    stake();
  }
}
  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()


