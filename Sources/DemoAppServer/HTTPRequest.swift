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
import Kitura
import LoggerAPI

func networkRequest(url: URL, method: String, payload: Data? = nil, authorization: String? = nil, cookies: [String: Any]? = nil, callback: @escaping (Data?, Int?, Swift.Error?) -> Void) {
    var request = URLRequest(url: url)
    request.httpMethod = method
    if let payload = payload {
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
    }
    if let auth = authorization {
        request.setValue(auth, forHTTPHeaderField: "Authorization")
    }
    if let cookies = cookies {
        var cookieString = ""
        for (cookieName, cookieValue) in cookies {
            cookieString += "\(cookieName)=\(cookieValue); "
        }
        request.setValue(cookieString, forHTTPHeaderField: "Cookie")
    }
    let requestTask = URLSession.shared.dataTask(with: request) {
        data, response, error in
        guard let httpResponse = response as? HTTPURLResponse else {
            callback(data, nil, error)
            return
        }
        callback(data, httpResponse.statusCode, error)
    }
    requestTask.resume()
}
