//
//  HTTPRequest.swift
//  SwiftEnterpriseDemo
//
//  Created by Jim Avery on 2/15/17.
//
//

import Foundation
import Kitura
import KituraNet
import LoggerAPI

enum HTTPError: Swift.Error {
    case BadURL
}

// Convert a Kitura response to a HTTPURLResponse.
func convertResponse(_ response: ClientResponse?) -> HTTPURLResponse? {
    guard let responseURL = response?.urlURL, let responseStatus = response?.status, let httpResponse = HTTPURLResponse(url: responseURL, statusCode: responseStatus, httpVersion: "HTTP/\(response?.httpVersionMajor).\(response?.httpVersionMinor)", headerFields: nil) else {
        return nil
    }
    return httpResponse
}

func networkRequest(url: URL, method: String, payload: Data? = nil, authorization: String? = nil, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) {
    #if os(macOS)
        requestWithURLSession(url: url, method: method, payload: payload, authorization: authorization, callback: callback)
    #else
        requestWithKitura(url: url, method: method, payload: payload, authorization: authorization, callback: callback)
    #endif
}

func requestWithURLSession(url: URL, method: String, payload: Data? = nil, authorization: String? = nil, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) {
    var request = URLRequest(url: url)
    request.httpMethod = method
    if let payload = payload {
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = payload
    }
    if let auth = authorization {
        request.setValue(auth, forHTTPHeaderField: "Authorization")
    }
    let requestTask = URLSession.shared.dataTask(with: request, completionHandler: callback)
    requestTask.resume()
}

func requestWithKitura(url: URL, method: String, payload: Data? = nil, authorization: String? = nil, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) {
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
        let httpResponse = convertResponse(response)
        do {
            let dataString = try response?.readString()
            let responseData = dataString?.data(using: String.Encoding.utf8)
            callback(responseData, httpResponse, nil)
        } catch {
            Log.error(error.localizedDescription)
            callback(nil, httpResponse, error)
        }
        return
    }
    if let payload = payload {
        request.write(from: payload)
    }
    request.end()
}
