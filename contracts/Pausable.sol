// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/GSN/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event PausedDeposit(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event UnpausedDeposit(address account);
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event PausedWithdraw(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event UnpausedWithdraw(address account);

    bool private _depositPaused;
    bool private _withdrawPaused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _depositPaused = false;
        _withdrawPaused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function pausedDeposit() public view returns (bool) {
        return _depositPaused;
    }

     /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function pausedWithdraw() public view returns (bool) {
        return _withdrawPaused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenDepositNotPaused() {
        require(!_depositPaused, "Pausable: Deposit paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenDepositPaused() {
        require(_depositPaused, "Pausable: Deposit not paused");
        _;
    }
    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenWithdrawNotPaused() {
        require(!_withdrawPaused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenWithdrawPaused() {
        require(_withdrawPaused, "Pausable: not paused");
        _;
    }


    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract Deposits must not be paused.
     */
    function pauseDeposit() internal virtual whenDepositNotPaused(){
        _depositPaused = true ;
        emit PausedDeposit(_msgSender());
    }

    function unpauseDeposit() internal virtual whenDepositPaused()  {
        _depositPaused = false;
        emit UnpausedDeposit(_msgSender());
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract Deposits must not be paused.
     */
    function pauseWithdraw() internal virtual whenWithdrawNotPaused(){
        _depositPaused = true ;
        emit PausedWithdraw(_msgSender());
    }

    function unpauseWithdraw() internal virtual  whenWithdrawPaused() {
        _withdrawPaused = false;
        emit UnpausedWithdraw(_msgSender());
    }
}
