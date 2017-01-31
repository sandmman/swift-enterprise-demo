var autoScalingController = function autoScalingController($http) {
    var self = this;
    self.memoryMessage = 'Waiting for user input.';
    self.cpuMessage = 'Waiting for user input.';
    self.memoryValue = 0;
    self.cpuValue = 0;
    
    self.requestMemory = function requestMemory(memValue) {
        $http.post('/memory', memValue)
        .then(function onSuccess(response) {
                self.memoryMessage = 'Success! Memory is being acquired.';
              },
              function onFailure(response) {
                var errStr = 'Failure with error code ' + response.status;
                if (response.data) {
                    errStr += ': ' + response.data;
                }
                self.memoryMessage = errStr;
        });
    };
    
    self.requestCPU = function requestCPU(cpuValue) {
        $http.post('/cpu', cpuValue)
        .then(function onSuccess(response) {
                self.cpuMessage = 'Success! CPU is being utilized.';
              },
              function onFailure(response) {
                var errStr = 'Failure with error code ' + response.status;
                if (response.data) {
                    errStr += ': ' + response.data;
                }
                self.cpuMessage = errStr;
        });
    };
};
