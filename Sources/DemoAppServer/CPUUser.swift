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

class CPUUser {
    class CPULock {
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
    
    var lock: CPULock
    
    init() {
        self.lock = CPULock(0)
    }
    
    func utilizeCPU(cpuPercent: Double) {
        // Increment the lock.
        self.lock.incrementState()
        
        // If cpuPercent is 0 or less, don't bother creating new threads.
        guard cpuPercent > 0 else {
            return
        }
        
        let currentState = self.lock.state
        // Obtain the number of possible cores and spawn a thread on each.
        let numCores = ProcessInfo.processInfo.activeProcessorCount
        let cpuWorkItem = {
            // Calculate the amount of time to spend working for each CPU, but make sure it
            // doesn't exceed 100% of the time.
            let cpuFraction = max((-(cpuPercent / 100.0) * (Double(numCores+1) / Double(numCores))), -1)
            let workInterval: TimeInterval = TimeInterval(cpuFraction)
            let sleepInterval: UInt32 = max(UInt32((1 + workInterval) * 1_000_000), 0)
            let startDate = Date()
            var sleepDate = Date()
            let continueState = currentState
            print("Start")
            while startDate.timeIntervalSinceNow > -600 && continueState == self.lock.state {
                //while startDate.timeIntervalSinceNow > -600 {
                if sleepDate.timeIntervalSinceNow < workInterval {
                    print("Sleep")
                    usleep(sleepInterval)
                    sleepDate = Date()
                }
            }
            print("End")
        }
        
        // Spawn the threads on separate queues.
        var queues = [DispatchQueue]()
        for i in 0..<numCores-1 {
            let cpuTaskQueue = DispatchQueue(label: "cpuQueue\(currentState)-\(i)", qos: DispatchQoS.userInitiated)
            queues.append(cpuTaskQueue)
            cpuTaskQueue.async(execute: cpuWorkItem)
        }
    }
}
