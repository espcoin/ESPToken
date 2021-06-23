// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/Math.sol";


contract EspToken is ERC20, Ownable {
	
	mapping (uint256 => address) private accountList;
	uint256 private numberOfAccounts;
	uint256 private finalSupply;

	constructor(uint256 _initialSupply, uint256 _finalSupply ) ERC20("E$P Token", "E$P"){
		_mint(msg.sender, _initialSupply);

		finalSupply = _finalSupply;

		// Variables used to randomly select accounts to distrubute tax to

		accountList[0] = owner();
		numberOfAccounts = 1;


	}

	   function transfer(address recipient, uint256 amount) public override virtual returns (bool) {

	   	//Tax Burn & Distribute

	   	uint256 _burnAmount;

	   	_burnAmount = amount / 200; 

	   	if(balanceOf(recipient) == 0) {
	   		accountList[numberOfAccounts] = recipient;
	   		numberOfAccounts += 1;

	   	}


	   	if (totalSupply() >= finalSupply ) {
	   		//transfer Tokents frist to owner, then immediately burn
	   		_transfer(_msgSender(), owner(), _burnAmount * 2);
	   		_burn(owner(), _burnAmount);
	   		//send equal amount to be distributed.   
	   		_distribute(_burnAmount);
	   } else {

	   		_distribute(_burnAmount * 2);
	   }

        _transfer(_msgSender(), recipient, (amount - _burnAmount * 2));

        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        
	   	//Tax Burn & Distribute

	   	uint256 _burnAmount;

	   	_burnAmount = amount / 200; 

	   	if(balanceOf(recipient) == 0) {
	   		accountList[numberOfAccounts] = recipient;
	   		numberOfAccounts += 1;

	   	}


	   	if (totalSupply() >= finalSupply ) {
	   		//transfer Tokents frist to owner, then immediately burn
	   		_transfer(sender, owner(), _burnAmount * 2);
	   		_burn(owner(), _burnAmount);
	   		//send equal amount to be distributed.   
	   		_distribute(_burnAmount);
	   } else {

	   		_distribute(_burnAmount * 2);
	   }

        _transfer(sender, recipient, (amount - _burnAmount * 2));

        uint256 currentAllowance = allowance(sender,_msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }




    function adminTransfer(address recipient, uint256 amount) public virtual onlyOwner returns  (bool) {
    	
    	//No Tax Transfer From Admin Account

    	if(balanceOf(recipient) == 0) {
	   		accountList[numberOfAccounts] = recipient;
	   		numberOfAccounts += 1;

	   	}

    	_transfer(owner(), recipient, amount);

    	return true;

    }

    function adminBurn(uint256 _amount) public virtual onlyOwner returns (bool) {

    	_burn(owner(), _amount);

    	return true;
    }


    function _distribute(uint256 _amount) internal virtual {
    	
    	uint256 _select;


    	require(numberOfAccounts != 0);

    	_select = block.number % numberOfAccounts;	

    	if (balanceOf(accountList[_select]) != 0) {
    		_transfer(owner(), accountList[_select], _amount);
    	} 
    }

    function numOfAccounts() public view virtual onlyOwner returns (uint256) {
    	return numberOfAccounts;
    }

}