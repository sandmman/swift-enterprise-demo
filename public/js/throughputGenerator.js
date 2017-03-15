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

function createRequests(workerNum, numRequests, endpoint) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', endpoint, true);
    xhr.onreadystatechange = function() {
        if (this.readyState == 4) {
            if (this.status != 200) {
                self.postMessage({type: 'error', status: this.status, message: xhr.responseText});
            }
        }
    };
    xhr.send();
}

this.onmessage = function(e) {
    var workerNum = e.data.workerNum;
    var interval = e.data.interval;
    var numRequests = e.data.requests;
    var endpoint = e.data.endpoint;
    
    if (interval) {
        clearInterval(interval);
    }
    
    if (workerNum < numRequests) {
        var newInterval = setInterval(function() {createRequests(workerNum, numRequests, endpoint);}, 1000);
        self.postMessage({type: 'interval', workerNum: workerNum, interval: newInterval});
    }
};
