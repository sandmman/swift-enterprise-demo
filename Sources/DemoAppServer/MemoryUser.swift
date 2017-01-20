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

class MemoryUser {
    let megabytes: Int
    let memoryPointer: UnsafeMutablePointer<Int8>?
    
    init(usingMB megabytes: Int) {
        self.megabytes = megabytes
        if megabytes <= 0 {
            self.memoryPointer = nil
        } else {
            let pointer = UnsafeMutablePointer<Int8>.allocate(capacity: megabytes * 1048576)
            pointer.initialize(to: 1, count: megabytes * 1048576)
            self.memoryPointer = pointer
        }
        
        print("MemoryUser initialized with \(self.megabytes) MB of memory")
    }
    
    deinit {
        if self.megabytes > 0, let pointer = self.memoryPointer {
            pointer.deinitialize(count: megabytes * 1048576)
            pointer.deallocate(capacity: megabytes * 1048576)
        }
        print("MemoryUser deinitialized, freeing \(self.megabytes) MB of memory")
    }
}
