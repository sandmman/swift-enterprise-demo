var KILOBYTES = 1024;
var MEGABYTES = 1048576;
var GIGABYTES = 1073741824;

var homeController = function homeController($scope, $http) {
    $scope.displayedTab = 'autoScaling';
    $scope.memoryMax = 256 * 0.875 * MEGABYTES;
    $scope.memoryStep = 32 * MEGABYTES;
    $scope.memoryUnit = MEGABYTES;
    $scope.memoryUnitLabel = "MB";
    $scope.dashboardLink = '/swiftdash';
    $scope.circuitClosed = true;
    
    $scope.getInitData = function getInitData() {
        $http.get('/initData')
        .then(function onSuccess(response) {
                //$scope.memoryMax = response.data.memoryMax;
                $scope.dashboardLink = response.data.monitoringURL;
                console.log(response);
              },
              function onFailure(response) {
                 console.log('Failed to get initial data from server.');
              });
    };
    
    $scope.setMemoryBounds = function setMemoryBounds(numBytes) {
        
    };
    
    setInterval(function () {
        $http.get('/requestJSON')
        .then(function onSuccess(response) {}, function onFailure(response) {
            console.log('Failed to get response from server.');
        });
    }, 5000);
};
