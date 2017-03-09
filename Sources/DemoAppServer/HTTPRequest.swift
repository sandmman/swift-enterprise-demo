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
import KituraNet
import LoggerAPI

enum HTTPError: Swift.Error {
    case BadURL
}

func networkRequest(url: URL, method: String, payload: Data? = nil, authorization: String? = nil, cookies: [String: Any]? = nil, callback: @escaping (Data?, Int?, Swift.Error?) -> Void) {
    #if os(macOS)
        requestWithURLSession(url: url, method: method, payload: payload, authorization: authorization, callback: callback)
    #else
        requestWithKitura(url: url, method: method, payload: payload, authorization: authorization, callback: callback)
    #endif
}

func requestWithURLSession(url: URL, method: String, payload: Data? = nil, authorization: String? = nil, cookies: [String: Any]? = nil, callback: @escaping (Data?, Int?, Swift.Error?) -> Void) {
    var request = URLRequest(url: url)
    request.httpMethod = method
    if let payload = payload {
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
    }
    if let auth = authorization {
        request.setValue(auth, forHTTPHeaderField: "Authorization")
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

func requestWithKitura(url: URL, method: String, payload: Data? = nil, authorization: String? = nil, cookies: [String: Any]? = nil, callback: @escaping (Data?, Int?, Swift.Error?) -> Void) {
    guard let urlComponents = URLComponents(string: url.absoluteString), let host = urlComponents.host, let schema = urlComponents.scheme else {
        callback(nil, nil, HTTPError.BadURL)
        return
    }
    
    var headers: [String: String] = [:]
    if method == "POST" {
        headers["Content-Type"] = "application/json; charset=utf-8"
    }
    if let auth = authorization {
        headers["Authorization"] = auth
    }
    let options: [ClientRequest.Options] = [.method(method), .hostname(host), .path(urlComponents.path), .schema(schema), .headers(headers)]
    let request = HTTP.request(options) {
        response in
        do {
            let dataString = try response?.readString()
            let responseData = dataString?.data(using: String.Encoding.utf8)
            callback(responseData, response?.httpStatusCode.rawValue, nil)
        } catch {
            Log.error(error.localizedDescription)
            callback(nil, response?.httpStatusCode.rawValue, error)
        }
        return
    }
    if let payload = payload {
        request.write(from: payload)
    }
    request.end()
}
