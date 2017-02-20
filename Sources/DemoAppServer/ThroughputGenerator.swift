//
//  ThroughputGenerator.swift
//  SwiftEnterpriseDemo
//
//  Created by Jim Avery on 2/15/17.
//
//

import Foundation
import Configuration
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
    
    init() {
        self.lock = ThroughputLock(0)
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
    
    func generateThroughputWithWhile(config: Configuration, requestsPerSecond: Int) {
        // Increment the lock.
        self.lock.incrementState()
        
        // If requestsPerSecond is 0 or less, don't bother creating new threads.
        guard requestsPerSecond > 0 else {
            return
        }
        
        var requestURL = "http://localhost:8080/requestJSON"
        let appData = config.getAppEnv()
        if appData.isLocal == false {
            requestURL = "\(appData.url)/requestJSON"
        }
        
        let currentState = self.lock.state
        // The work item to execute.
        let requestWorkItem = {
            let startDate = Date()
            var waitDate = Date()
            let continueState = currentState
            while startDate.timeIntervalSinceNow > -600 && continueState == self.lock.state {
                if waitDate.timeIntervalSinceNow < -1 {
                    waitDate = Date()
                    // Make a request, don't worry about the result.
                    if let requestURL = URL(string: requestURL) {
                        networkRequest(url: requestURL, method: "GET") {
                            data, response, error in
                            return
                        }
                    }
                }
                // Sleep for 0.1 seconds.
                usleep(100_000)
            }
        }
        
        // Create the threads.
        var queues = [DispatchQueue]()
        for i in 0..<requestsPerSecond {
            let throughputTaskQueue = DispatchQueue(label: "throughputQueue\(currentState)-\(i)", qos: DispatchQoS.userInitiated)
            queues.append(throughputTaskQueue)
            throughputTaskQueue.async(execute: requestWorkItem)
        }
    }
}
