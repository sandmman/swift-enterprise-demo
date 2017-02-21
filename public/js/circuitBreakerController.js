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

    
    self.invokeCircuit = function invokeCircuit() {
        $http.get('/invokeCircuit', {timeout: 10000})
        .then(function onSuccess(response) {
            self.circuitMessage = "Request successful.";
        },
        function onFailure(response) {
            switch (response.status) {
            case 400:
                self.circuitMessage = "Bad request. URL invalid.";
                break;
            case 417:
                self.circuitMessage = "Request failed.";
                break;
            case 500:
                self.circuitMessage = "Internal server error. Could not parse response from Kitura-Starter.";
                break;
            default:
                self.circuitMessage = "Unknown error " + response.status + ": " + response.statusText + ".";
                break;
            }
        });
    };
};
