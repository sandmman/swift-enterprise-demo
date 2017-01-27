/**
 * Copyright IBM Corporation 2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

// Processing alerts.

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

// Requesting memory usage.

function requestMemory() {
    // Grab the form data.
    var memory = document.getElementById("memoryToUse").value;

    // Send it.
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/memory');
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4) {
            if (xhr.status == 200) {
                document.getElementById("memoryResponse").innerHTML = "Success! Memory is being acquired.";
            } else {
                var errStr = "Failure with error code " + xhr.status;
                if (xhr.responseText) {
                    errStr += ": " + xhr.responseText;
                }
                document.getElementById("memoryResponse").innerHTML = errStr;
            }
        }
    };
    document.getElementById("memoryResponse").innerHTML = "Working...";
    xhr.send(memory);

    return false;
}

// Requesting memory usage.

function requestCPU() {
    // Grab the form data.
    var cpu = document.getElementById("cpuToUse").value;
    
    // Send it.
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/cpu');
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4) {
            if (xhr.status == 200) {
                document.getElementById("cpuResponse").innerHTML = "Success! CPU is being acquired.";
            } else {
                var errStr = "Failure with error code " + xhr.status;
                if (xhr.responseText) {
                    errStr += ": " + xhr.responseText;
                }
                document.getElementById("cpuResponse").innerHTML = errStr;
            }
        }
    };
    document.getElementById("cpuResponse").innerHTML = "Working...";
    xhr.send(cpu);
    
    return false;
}

// Observing metrics.

var GIGABYTES = 1073741824;
var MEGABYTES = 1048576;
var KILOBYTES = 1024;

function convertToHigherBytes(bytes) {
    if (bytes > GIGABYTES) {
        return (bytes / GIGABYTES).toPrecision(5) + " GB";
    } else if (bytes > MEGABYTES) {
        return (bytes / MEGABYTES).toPrecision(5) + " MB";
    } else if (bytes > KILOBYTES) {
        return (bytes / KILOBYTES).toPrecision(5) + " KB";
    } else {
        return bytes.toString() + " bytes";
    }
}

function requestMetrics() {
    // Send it.
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/metrics');
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4) {
            if (xhr.status == 200) {
                var metricsJSON = JSON.parse(xhr.responseText);
                var metricsString = "<br>CPU used by application: " + metricsJSON.cpuUsedByApplication.toPrecision(4) + "%</br>";
                metricsString += "<br>CPU used by system: " + metricsJSON.cpuUsedBySystem.toPrecision(4) + "%</br>";
                metricsString += "<br>Total RAM on system: " + convertToHigherBytes(metricsJSON.totalRAMOnSystem) + "</br>";
                metricsString += "<br>Total RAM used: " + convertToHigherBytes(metricsJSON.totalRAMUsed) + "</br>";
                metricsString += "<br>Total RAM free: " + convertToHigherBytes(metricsJSON.totalRAMFree) + "</br>";
                metricsString += "<br>Application address space size: " + convertToHigherBytes(metricsJSON.applicationAddressSpaceSize) + "</br>";
                metricsString += "<br>Application private size: " + convertToHigherBytes(metricsJSON.applicationPrivateSize) + "</br>";
                metricsString += "<br>Application RAM used: " + convertToHigherBytes(metricsJSON.applicationRAMUsed) + "</br>";
                document.getElementById("metricsResponse").innerHTML = metricsString;
            } else {
                document.getElementById("metricsResponse").innerHTML = "Failure with error code " + xhr.status + ". " + xhr.responseText;
            }
        }
    };
    xhr.send();

    return false;
}

setInterval(requestMetrics, 2000);
