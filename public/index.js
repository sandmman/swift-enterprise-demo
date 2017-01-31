var angular;

angular.module("demoApp", [])
.config(config)
.controller('homeController', homeController)
.controller('autoScalingController', autoScalingController)
.controller('circuitBreakerController', circuitBreakerController);

function config($compileProvider) {
    $compileProvider.debugInfoEnabled(false);
}
