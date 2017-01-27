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

class CPULock {
    //private var internalState: Int
    //private let internalQueue: DispatchQueue
    
    //var state: Int {
    //    get {
    //        return internalQueue.sync { internalState }
    //    }
    
    //    set (newState) {
    //        internalQueue.sync { internalState = newState }
    //    }
    //}
    
    //init(_ state: Int) {
    //    self.internalState = state
    //    self.internalQueue = DispatchQueue(label: "lock-\(state)")
    //}
    
    //func incrementState() {
    //    if self.state >= 1000 {
    //        self.state = 0
    //    } else {
    //        self.state += 1
    //    }
    //}
    
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
