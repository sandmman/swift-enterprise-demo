var angular;

angular.module("demoApp", ['ngWebSocket'])
.config(config)
.factory('websocketFactory', websocketFactory)
.controller('homeController', homeController)
.controller('autoScalingController', autoScalingController)
.controller('circuitBreakerController', circuitBreakerController);

function config($compileProvider) {
    $compileProvider.debugInfoEnabled(false);
}
