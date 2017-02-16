var circuitBreakerController = function circuitBreakerController($http) {
    var self = this;
    self.circuitMessage = "Waiting for user input.";
    
    self.checkCircuit = function checkCircuit() {
        $http.get('/checkCircuit/timeout')
        .then(function onSuccess(response) {
            self.circuitMessage = "The circuit is currently closed.";
        },
        function onFailure(response) {
            var errStr = 'Failure with error code ' + response.status;
            if (response.data) {
                errStr += ': ' + response.data;
            }
            console.log(errStr);
            self.circuitMessage = "The circuit is currently open.";
        });
    };
};
