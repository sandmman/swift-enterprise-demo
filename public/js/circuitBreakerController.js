var circuitBreakerController = function circuitBreakerController($http) {
    var self = this;
    
    self.checkCircuit = function checkCircuit() {
        console.log("Tick");
        $http.get('/checkCircuit/timeout')
        .then(function onSuccess(response) {
            console.log('Success! Memory is being acquired.');
        },
        function onFailure(response) {
            var errStr = 'Failure with error code ' + response.status;
            if (response.data) {
                errStr += ': ' + response.data;
            }
            console.log(errStr);
        });
    };
};
