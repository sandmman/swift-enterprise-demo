var homeController = function homeController($scope, $http) {
    $scope.displayedTab = "autoScaling";
    $scope.memoryMax = 256 * 0.875;
    $scope.memoryStep = 32;
    
    $scope.getInitData = function getInitData() {
        $http.get('/initData')
        .then(function onSuccess(response) {
                //$scope.memoryMax = response.data.memoryMax;
                console.log(response);
              },
              function onFailure(response) {
                 console.log("Failed to get initial data from server.");
              });
    };
};
