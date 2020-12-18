# 🏝 BLOCK-pension
Block pension allows anyone to register and sponsor a beneficiary's pension while also allowing anybody to contribute to it.

A real world scenario would be a contributory pension scheme where employers contribute certain amounts and percentage of their employees salary towards their retirement. This funds are usually managed by Pension fund custodians and administrators and the beneficiary/employee has little to no control over where their funds are invested or what their funds are being used for. Most times these investments yield low to no returns on the beneficiary's contribution. 

With Block pension contributions made to a beneficiary's pension are invested by a pension fund admin in defi protocols in other to earn and accumulate interest while contributions and withdrawals are made to and fro it. Block-pension aims to enable the beneficiary decide on what their funds will be invested in depending on its returns. This is achieved with the Pension fund admin smart contract which could be implemented in any flavour, e.g A PFA that invests beneficiary pension in yearn vaults, decentralized lending and borrowing protocols like aave, money markets like compound or a combination of various protocols. Thus allowing the beneficiary to switch between different PFAs whom he or she feels earn higher yields on their pension (This is not yet fully integrated into the dapp). The PFA implemented in this dapp is very basic and just deposits the beneficiary's Pension into a Compound Market to earn interest. 

On retirement - which can be anytime, the beneficiary has the option of choosing to withdraw their pensions as annuities or withdrawing all of their pension/benefits at once.

A use case i find interesting would be that with the rising trend of anon devs in the crypto space, the crypto community most especially defi communities could setup and contribute to the retirement of their founders, developers and key stakeholders to incentivize and keep them motivated long term.

### link to my dapp walkthrough
https://www.youtube.com/watch?v=hge43th4htk

## 👩🏻‍💻 Development
* Prerequisites
* Node v10.21.0
* Truffle v5.1.30 (core: 5.1.30)
* Solidity - 0.6.0 (solc-js)


## 🛠 Setup
* Clone the repo using git clone https://github.com/ezchinonso/block-pension
* cd into block-pension and run `npm install` in the root directory of the project. 
* To run the frontend, cd into the client directory - `yarn install` and `yarn start` to start up the development server.

## ✅ Testing
You can run the tests by running `truffle test` from the root directory of the project.

## ToDo
Add more tests

Note: Smart contracts are deployed on ropsten testnet.

