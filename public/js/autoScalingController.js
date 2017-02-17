var autoScalingController = function autoScalingController($http) {
    var self = this;
    self.memoryMessage = 'Waiting for user input.';
    self.responseTimeMessage = 'Waiting for user input.';
    self.memoryValue = 0;
    self.cpuValue = 0;
    self.responseTimeValue = 0;
    
    self.displayMemoryValue = function displayMemoryValue(memVal, memUnit) {
        return (memVal/memUnit).toFixed(3);
    };
    
    self.requestMemory = function requestMemory(memValue) {
        self.memoryMessage = 'Sending request...';
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
        self.cpuMessage = 'Sending request...';
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
    
    self.setResponseDelay = function setResponseDelay(responseTime) {
        self.responseTimeMessage = 'Sending request...';
        $http.post('/responseTime', responseTime*1000)
        .then(function onSuccess(response) {
              self.responseTimeMessage = 'Success! Delay has been changed.';
              },
              function onFailure(response) {
              var errStr = 'Failure with error code ' + response.status;
              if (response.data) {
              errStr += ': ' + response.data;
              }
              self.responseTimeMessage = errStr;
              });
    };
};
