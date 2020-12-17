## Contract Factory
I used a contract factory to deploy instances of the pension fund admin, so that each beneficiary has a new instance managing their pensions which will reduce the amount of possible attack vectors.

## Circuit Breaker
A circuit breaker is used to prevent deposits or withdrawals during emergency i.e when an attacker is trying to drain pension funds

## Mortal
A pension fund admin self destructs when all the funds in it has being withdrawn by the beneficiary

## Speed Bump
A speed bump is implemented in the smart contracts to allow withdrawal only after every 28 days

