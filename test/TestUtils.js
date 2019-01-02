var appcInstance = null;
var contractInstance = null;

module.exports = {
	setAppCoinsInstance: function (instance){
		appcInstance = instance;
	},
	setContractInstance: function (instance){
		contractInstance = instance;
	},
	getBalance: async function (account) {
			var balance = await appcInstance.balanceOf.call(account);
			return JSON.parse(balance);
		},
	expectErrorMessageTest: async function (errorMessage,callback){
			var events = contractInstance.allEvents();

			await callback();
			var eventLog = await new Promise(
					function(resolve, reject){
			        events.watch(function(error, log){ events.stopWatching(); resolve(log); });
			    });

			assert.equal(eventLog.event, "Error", "Event must be an Error");
		    assert.equal(eventLog.args.message, errorMessage, "Event message should be: "+errorMessage);
		},
	expectEventTest: async function (eventName, callback){
		var events = contractInstance.allEvents();

		await callback();
		var eventLog = await new Promise(
				function(resolve,reject){
					events.watch(function(error,log){ events.stopWatching(); resolve(log); });
		});

		assert.equal(eventLog.event, eventName, "Expected event of type "+eventName);
	},
	expectRevertTest: async function (callback){
		var reverted = false;
		var expectRevert = RegExp('revert');
		await callback().catch(
			(err) => {
				reverted = expectRevert.test(err.message);
			}
		);

		assert.equal(reverted, true, "The transaction should have reverted.");
	},
	numberToBuffer: function (integer) {
		var length = Math.ceil((Math.log(integer)/Math.log(2))/8); // How much byte to store integer in the buffer
		var buffer = new Buffer(length);
		var arr = []; // Use to create the binary representation of the integer

		while (integer > 0) {
			var temp = integer % 2;
			arr.push(temp);
			integer = Math.floor(integer/2);
		}

		//console.log(arr);

		var counter = 0;
		var total = 0;

		for (var i = 0,j = arr.length; i < j; i++) {
			if (counter % 8 == 0 && counter > 0) { // Do we have a byte full ?
				buffer[length - 1] = total;
				total = 0;
				counter = 0;
				length--;      
			}

			if (arr[i] == 1) { // bit is set
				total += Math.pow(2, counter);
			}
			counter++;
		}

		buffer[0] = total;
		return buffer;
	}
}
