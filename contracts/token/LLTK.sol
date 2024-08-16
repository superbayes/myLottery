// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";

contract LuckyLadybugToken is ERC20, ERC20Burnable, ERC20Pausable, Ownable, ERC20FlashMint {
    constructor(address initialOwner)
        ERC20("luckyLadybugToken", "LLTK")
        Ownable(initialOwner)
    {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner  whenNotPaused{
        _mint(to, amount);
    }

    function burn(address account, uint256 value)  public onlyOwner whenNotPaused{
        _burn(account,value);
    }
    //
    // The following functions are overrides required by Solidity.
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
