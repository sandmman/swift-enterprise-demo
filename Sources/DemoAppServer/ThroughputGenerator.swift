//
//  ThroughputGenerator.swift
//  SwiftEnterpriseDemo
//
//  Created by Jim Avery on 2/15/17.
//
//

import Foundation
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
    
    init() {
        self.lock = ThroughputLock(0)
        self.queue = DispatchQueue(label: "throughputQueue", qos: DispatchQoS.userInitiated)
    }
    
    func generateBlock(lock: ThroughputLock, lockValue: Int) -> (Timer) -> Void {
        return { timer in
            print("Goose")
        }
    }
    
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
            print("Goose")
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
            print("Start")
            while startDate.timeIntervalSinceNow > -600 && continueState == self.lock.state {
                if sleepDate.timeIntervalSinceNow < workInterval {
                    usleep(sleepInterval)
                    sleepDate = Date()
                }
            }
            print("End")
        }
        
        // Spawn the threads.
        for _ in 0..<requestsPerSecond {
            self.queue.async(execute: requestWorkItem)
        }
    }*/
    
    /*func generateThroughputWithWhile(requestsPerSecond: Int) {
        // Increment the lock.
        self.lock.incrementState()
        
        // If requestsPerSecond is 0 or less, don't bother creating new threads.
        guard requestsPerSecond > 0 else {
            return
        }
        
        let currentState = self.lock.state
        //
        let requestWorkItem = {
            print("Goose")
            let startDate = Date()
            var waitDate = Date()
            let continueState = currentState
            while startDate.timeIntervalSinceNow > -600 && continueState == self.lock.state {
                if waitDate.timeIntervalSinceNow > -1 {
                    
                    waitDate = Date()
                }
            }
        }
    }*/
}
