var circuitBreakerController = function circuitBreakerController($http) {
    var self = this;
    self.circuitMessage = "Waiting for user input.";
    
    self.openCircuit = function openCircuit() {
        $http.get('/changeCircuit/open')
        .then(function onSuccess(response) {
            self.circuitMessage = "Change successful. The circuit is now open.";
        },
        function onFailure(response) {
            var errStr = 'Failure with error code ' + response.status;
            if (response.data) {
                errStr += ': ' + response.data;
            }
            self.circuitMessage = errStr;
        });
    };
    
    self.closeCircuit = function closeCircuit() {
        $http.get('/changeCircuit/close')
        .then(function onSuccess(response) {
            self.circuitMessage = "Change successful. The circuit is now closed.";
        },
        function onFailure(response) {
            var errStr = 'Failure with error code ' + response.status;
            if (response.data) {
                errStr += ': ' + response.data;
            }
            self.circuitMessage = errStr;
        });
    };

    
    self.checkCircuit = function checkCircuit() {
        $http.get('/checkCircuit/timeout');
    };
};
