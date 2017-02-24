var websocketFactory = function websocketFactory($websocket) {
    var dataStream = undefined;
    
    return {
        setEndpoint: function(endpoint) {
            dataStream = $websocket(endpoint);
        },
        onStateChange: function(callback) {
            dataStream.onMessage(callback);
        }
    };
};
