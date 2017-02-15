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

func requestWithURLSession(url: URL, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    let requestTask = URLSession.shared.dataTask(with: request, completionHandler: callback)
    requestTask.resume()
}

func requestWithKitura(url: URL, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) {
    guard let urlComponents = URLComponents(string: url.absoluteString), let host = urlComponents.host, let schema = urlComponents.scheme else {
        callback(nil, nil, HTTPError.BadURL)
        return
    }
    
    let options: [ClientRequest.Options] = [.method("GET"), .hostname(host), .path(urlComponents.path), .schema(schema)]
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
    request.end()
}
