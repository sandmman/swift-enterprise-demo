function sendAlert() {
    // Grab the form data.
    var summary = document.getElementById("summary").value;
    var location = document.getElementById("location").value;
    var severity = parseInt(document.getElementById("severity").value, 10);
    
    // Pack it.
    var alertObj = {
        summary: summary,
        location: location,
        severity: severity
    };
    
    // Send it.
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/alert');
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4) {
            if (xhr.status == 200) {
                document.getElementById("postResponse").innerHTML = "Success! Alert ID is " + xhr.responseText + ".";
            } else {
                var errStr = "Failure with error code " + xhr.status;
                if (xhr.responseText) {
                    errStr += ": " + xhr.responseText;
                }
                document.getElementById("postResponse").innerHTML = errStr;
            }
        }
    };
    document.getElementById("postResponse").innerHTML = "Working...";
    xhr.send(JSON.stringify(alertObj));
    
    return false;
}

function deleteAlert() {
    // Grab the form data.
    var shortid = document.getElementById("shortid").value;
    
    // Send it.
    var xhr = new XMLHttpRequest();
    xhr.open('DELETE', '/alert');
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4) {
            if (xhr.status == 200) {
                document.getElementById("deleteResponse").innerHTML = "Success! Alert has been deleted.";
            } else {
                var errStr = "Failure with error code " + xhr.status;
                if (xhr.responseText) {
                    errStr += ": " + xhr.responseText;
                }
                document.getElementById("deleteResponse").innerHTML = errStr;
            }
        }
    };
    document.getElementById("deleteResponse").innerHTML = "Working...";
    xhr.send(shortid);
    
    return false;
}

function requestMetrics() {
    // Send it.
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/metrics');
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4) {
            if (xhr.status == 200) {
                console.log(xhr.responseText);
            } else {
                console.log("Failure with error code " + xhr.status);
                console.log(xhr.responseText);
            }
        }
    };
    xhr.send();
    
    return false;
}
