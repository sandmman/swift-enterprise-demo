//
//  AutoScalingPolicy.swift
//  SwiftEnterpriseDemo
//
//  Created by Jim Avery on 2/23/17.
//
//

import Foundation

class AutoScalingPolicy {
    enum MetricType: String {
        case Memory, Throughput, ResponseTime
    }
    
    class PolicyTrigger {
        let metricType: MetricType
        let lowerThreshold: Int
        let upperThreshold: Int
        
        init(metricType: MetricType, lowerThreshold: Int, upperThreshold: Int) {
            self.metricType = metricType
            self.lowerThreshold = lowerThreshold
            self.upperThreshold = upperThreshold
        }
    }
    
    let policyTriggers: [PolicyTrigger]
    
    init?(data: Data) {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = json as? [String: Any] else {
            return nil
        }
        
        guard let policyState = dictionary["policyState"] as? String, policyState == "ENABLED" else {
            return nil
        }
        
        guard let triggers = dictionary["policyTriggers"] as? [[String: Any]] else {
            return nil
        }
        
        var triggerArray: [PolicyTrigger] = [PolicyTrigger]()
        for trigger in triggers {
            guard let metricTypeRawValue = trigger["metricType"] as? String, let metricType = MetricType(rawValue: metricTypeRawValue) else {
                continue
            }
            
            guard let lowerThreshold = trigger["lowerThreshold"] as? Int else {
                continue
            }
            
            guard let upperThreshold = trigger["upperThreshold"] as? Int else {
                continue
            }
            
            triggerArray.append(PolicyTrigger(metricType: metricType, lowerThreshold: lowerThreshold, upperThreshold: upperThreshold))
        }
        
        guard triggerArray.count > 0 else {
            return nil
        }
        
        self.policyTriggers = triggerArray
    }
}
