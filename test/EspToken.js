var EspToken = artifacts.require("./EspToken.sol");

contract('EspToken', function(accounts) {
	var tokenInstance;
	var testAmount;

	it('initializes the contract with the correct values', function() {
		return EspToken.deployed().then(function(instance){
			tokenInstance = instance;
			return tokenInstance.name();
		}).then(function(name) {
			assert.equal(name, 'E$P Token', 'has the correct name');
			return tokenInstance.symbol();
		}).then(function(symbol) {
			assert.equal(symbol, 'E$P', 'Has the correct symbol');
			return tokenInstance.owner();
		}).then(function(owner) {
			assert.equal(owner, accounts[0], 'Has creater as admin');
		});
	});

	it('sets the total supply upon deployment', function() {
		return EspToken.deployed().then(function(instance) {
			tokenInstance = instance;
			return tokenInstance.totalSupply();

		}).then(function(totalSupply) {
			assert.equal(totalSupply.toNumber(), 500000 , 'sets the total supply to 1000');
		//	console.log(totalSupply);
			return tokenInstance.balanceOf(accounts[0]);
		}).then(function(adminBalance) {
			assert.equal(adminBalance.toNumber(), 500000 , 'has allocated total supply to admin');
		//	console.log(adminBalance);
		});
	});



	it('transfers token ownership with fee' , function() {
		return EspToken.deployed().then(function(instance) {
			tokenInstance = instance;
			testAmount = 10000;
		return tokenInstance.transfer.call(accounts[0], 999999);
		}).then(assert.fail).catch(function (error) {
			assert(error.message.indexOf('revert') >= 0, 'error message must contain revert');
			return tokenInstance.transfer.call(accounts[1], 250 , {from: accounts[0]});
		}).then(function(success) {
			assert(success, true, 'transfer returns true');
			return tokenInstance.transfer(accounts[2], testAmount, {from: accounts[0]});
		}).then(function(receipt) {
			console.log('Amount Sent Then Amount Burnt');
			console.log(receipt.logs[1].args.value.toNumber());
			assert.equal(receipt.logs.length, 3, 'triggers one event');
			assert.equal(receipt.logs[2].event, 'Transfer', 'should be the transfer event');
			assert.equal(receipt.logs[2].args.from, accounts[0], 'logs the account the tokens are from');
			assert.equal(receipt.logs[2].args.to, accounts[2], 'logs the account the tokens sent to');
			assert.equal(receipt.logs[2].args.value.toNumber(), Math.ceil((testAmount) - ( (testAmount) / 200)), 'logs the number of tokens sent');
			return tokenInstance.balanceOf(accounts[2]);
		}).then(function(balance) {
			assert.equal(balance.toNumber(), Math.ceil((testAmount ) - ((testAmount ) / 200) ), 'Make sure receipient balance is ok') ;
			return tokenInstance.balanceOf(accounts[0]);
		}).then(function(adminBalance) {	
			assert.equal(adminBalance.toNumber(), (500000 - testAmount), 'Make sure sending balance is correct');
			return tokenInstance.totalSupply();
		}).then(function(totalSupply){
			assert.equal(totalSupply.toNumber(), Math.round(500000 - (testAmount/200)), 'Make sure the total supply is correct after burn');
		}); 
	});
});