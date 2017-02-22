var circuitBreakerController = function circuitBreakerController($http) {
    var self = this;
    self.hostURL = "http://kitura-starter-spatterdashed-preliberality.stage1.mybluemix.net";
    self.hostPort = undefined;
    self.hostMessage = "Current microservice endpoint is " + self.hostURL;
    self.circuitMessage = "Waiting for user input.";
    
    self.changeURL = function changeURL(host, port) {
        self.hostMessage = "Working...";
        $http.post('/changeEndpoint', {host: host, port: port})
        .then(function onSuccess(response) {
            self.hostMessage = "URL successfully changed to " + response.data;
        },
        function onFailure(response) {
            var errStr = 'Failure with error code ' + response.status;
            if (response.data) {
                errStr += ': ' + response.data;
            }
            self.hostMessage = errStr;
        });
    };
    
    self.openCircuit = function openCircuit() {
        self.circuitMessage = "Working...";
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
        self.circuitMessage = "Working...";
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
        self.circuitMessage = "Working...";
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
