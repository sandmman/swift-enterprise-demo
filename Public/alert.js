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
                console.log("Success!")
            } else {
                console.log("Failure with error code " + xhr.status);
            }
        }
    };
    xhr.send(JSON.stringify(alertObj));
    
    return false;
}
