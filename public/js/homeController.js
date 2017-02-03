var homeController = function homeController($scope, $http) {
    $scope.displayedTab = "autoScaling";
    $scope.memoryMax = 256;
    $scope.memoryStep = 32;
    
    var getInitData = function getInitData() {
        $http.get('/initData')
        .then(function onSuccess(response) {
              {
                $scope.memoryMax = response.data.memoryMax;
              },
              function onFailure(response) {
                 console.log("Failed to get initial data from server.");
              });
    };
};
