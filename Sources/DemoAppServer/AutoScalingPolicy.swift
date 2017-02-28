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
import AlertNotifications
import Configuration
import CloudFoundryEnv

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
    var totalSystemRAM: Int? = nil

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

    func checkPolicyTriggers(metric: MetricType, value: Int, configMgr: ConfigurationManager, usingCredentials credentials: ServiceCredentials) {
        for trigger in self.policyTriggers {
            if trigger.metricType == metric {
                switch metric {
                case .Memory:
                    // Memory is unique in that it is percentage-based.
                    if let totalRAM = self.totalSystemRAM {
                        let RAMThreshold = (totalRAM * trigger.upperThreshold) / 100
                        if value > RAMThreshold {
                            sendAlert(type: metric, configMgr: configMgr, usingCredentials: credentials) {
                                alert, error in
                                if error != nil {
                                    print("Failed to send alert on excessive \(metric)")
                                } else {
                                    print("Alert sent on excessive \(metric)")
                                }
                            }
                        }
                    }
                    break
                default:
                    if value > trigger.lowerThreshold {
                        sendAlert(type: metric, configMgr: configMgr, usingCredentials: credentials) {
                            alert, error in
                            if error != nil {
                                print("Failed to send alert on excessive \(metric)")
                            } else {
                                print("Alert sent on excessive \(metric)")
                            }
                        }
                    }
                }
            }
        }
    }
}
