var homeController = function homeController($scope, $http) {
    $scope.displayedTab = 'autoScaling';
    $scope.memoryMax = 256 * 0.875;
    $scope.memoryStep = 32;
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
    
    setInterval(function () {
        $http.get('/requestJSON')
        .then(function onSuccess(response) {}, function onFailure(response) {
            console.log('Failed to get response from server.');
        });
    }, 5000);
};
