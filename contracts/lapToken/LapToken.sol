// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract LapToken is ERC20BurnableUpgradeable, OwnableUpgradeable {
    mapping(address => bool) public minters;

    modifier onlyMinter() {
        require(isMinter(msg.sender), "NOT_MiNTER");
        _;
    }

    function initialize() public virtual initializer {
        uint256 initialSupply = 850000 * 1e18;
        __Ownable_init();
        __ERC20_init("LAPToken", "LAP");
        __ERC20Burnable_init();
        addMinter(msg.sender);
        mint(msg.sender, initialSupply);
    }

    function mint(address _to, uint256 _amount) public onlyMinter {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) public onlyMinter {
        _burn(_from, _amount);
    }

    function addMinter(address _account) public virtual onlyOwner {
        require(!isMinter(_account), "ALREADY_MINTER");
        minters[_account] = true;
    }

    function removeMinter(address _account) public virtual onlyOwner {
        require(isMinter(_account), "NOT_MINTER");
        minters[_account] = false;
    }

    function isMinter(address _account) public view virtual returns (bool) {
        return minters[_account];
    }
}
