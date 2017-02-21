var websocketFactory = function websocketFactory($websocket) {
    var dataStream = $websocket('ws://localhost:8080/circuit');
    
    return {
        onStateChange: function(callback) {
            dataStream.onMessage(callback);
        }
    };
};
