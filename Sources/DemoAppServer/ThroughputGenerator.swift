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

import Foundation
import Configuration
import CloudFoundryEnv
#if os(Linux)
    import Dispatch
#endif

class ThroughputGenerator {
    class ThroughputLock {
        var state: Int8

        init(_ state: Int8) {
            self.state = state
        }

        func incrementState() {
            if self.state >= 100 {
                self.state = 0
            } else {
                self.state += 1
            }
        }
    }

    var lock: ThroughputLock
    var queue: DispatchQueue
    var requestsPerSecond: Int

    init() {
        self.lock = ThroughputLock(0)
        self.queue = DispatchQueue(label: "throughputQueue", attributes: .concurrent)
        self.requestsPerSecond = 0
    }

    /*func generateBlock(lock: ThroughputLock, lockValue: Int) -> (Timer) -> Void {
        return { timer in
            print("Timer started")
        }
    }*/

    /*@available(macOS 10.12, *)
    func generateThroughput(requestsPerSecond: Int) {
        // Increment the lock.
        self.lock.incrementState()

        // If requestsPerSecond is 0 or less, don't bother creating new threads.
        guard requestsPerSecond > 0 else {
            return
        }

        let currentState = self.lock.state
        //
        let requestWorkItem = {
            let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
                timer in
                return
            }
            let cpuFraction = max((-(cpuPercent / 100.0) * (Double(numCores+1) / Double(numCores))), -1)
            let workInterval: TimeInterval = TimeInterval(cpuFraction)
            let sleepInterval: UInt32 = max(UInt32((1 + workInterval) * 1_000_000), 0)
            let startDate = Date()
            var sleepDate = Date()
            let continueState = currentState
            while startDate.timeIntervalSinceNow > -600 && continueState == self.lock.state {
                if sleepDate.timeIntervalSinceNow < workInterval {
                    usleep(sleepInterval)
                    sleepDate = Date()
                }
            }
        }

        // Spawn the threads.
        for _ in 0..<requestsPerSecond {
            self.queue.async(execute: requestWorkItem)
        }
    }*/

    func generateThroughputWithWhile(configMgr: ConfigurationManager, requestsPerSecond: Int, vcapCookie: String?) {
        // Set the field.
        self.requestsPerSecond = requestsPerSecond
        
        // Increment the lock.
        self.lock.incrementState()

        // If requestsPerSecond is 0 or less, don't bother creating new threads.
        guard requestsPerSecond > 0 else {
            return
        }

        var requestURL = "http://localhost:8080/requestJSON"
        if configMgr.isLocal == false {
            requestURL = "\(configMgr.url)/requestJSON"
        }

        let currentState = self.lock.state
        
        for _ in 0..<requestsPerSecond {
            self.queue.async(execute: {
                let startDate = Date()
                var waitDate = Date()
                let continueState = currentState
                while startDate.timeIntervalSinceNow > -600 && continueState == self.lock.state {
                    if waitDate.timeIntervalSinceNow < -1 {
                        waitDate = Date()
                        // Make a request, don't worry about the result.
                        if let requestURL = URL(string: requestURL) {
                            var cookies: [String: Any] = [:]
                            if configMgr.isLocal == false, let appData = configMgr.getApp(), let vcap = vcapCookie {
                                cookies["JSESSIONID"] = "\(appData.instanceIndex)"
                                cookies["__VCAP_ID__"] = vcap
                            }
                            networkRequest(url: requestURL, method: "GET", cookies: cookies) {
                                data, response, error in
                                return
                            }
                        }
                    }
                    // Sleep for 0.1 seconds.
                    usleep(100_000)
                }
            })
        }
    }
}
