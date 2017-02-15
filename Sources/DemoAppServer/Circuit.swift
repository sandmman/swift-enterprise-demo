//
//  Circuit.swift
//  SwiftEnterpriseDemo
//
//  Created by Jim Avery on 2/13/17.
//
//

import Foundation
import Kitura
import KituraNet
import CircuitBreaker

enum CircuitError: Error {
    case BadURL
}

func timeoutCallbackGenerator(response: RouterResponse, next: @escaping () -> Void) -> (BreakerError) -> Void {
    return { err in
        print("Failed")
        switch err {
        case BreakerError.timeout:
            response.status(.internalServerError).send("Operation timed out. Circuit open.")
        case BreakerError.fastFail:
            response.status(.internalServerError).send("Circuit open.")
        }
        next()
    }
}

func requestWithURLSession(url: URL, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
    guard let circuitURL = URL(string: "/json", relativeTo: url) else {
        callback(nil, nil, CircuitError.BadURL)
        return
    }
    
    var request = URLRequest(url: circuitURL)
    request.httpMethod = "GET"
    let requestTask = URLSession.shared.dataTask(with: request, completionHandler: callback)
    requestTask.resume()
}

func requestWithKitura(url: URL, response: RouterResponse, next: @escaping () -> Void) {
    guard let circuitURL = URL(string: "/json", relativeTo: url) else {
        response.status(.badRequest).send("Bad URL sent. Cannot report circuit status.")
        next()
        return
    }
    
    guard let urlComponents = URLComponents(string: circuitURL.absoluteString), let host = urlComponents.host, let schema = urlComponents.scheme else {
        response.status(.badRequest).send("Bad URL sent. Cannot report circuit status.")
        next()
        return
    }
    
    let options: [ClientRequest.Options] = [.method("GET"), .hostname(host), .path(urlComponents.path), .schema(schema)]
    let request = HTTP.request(options) {
        response in
        return
    }
    request.end()
}

func requestWrapper(forURL url: URL, response: RouterResponse, next: @escaping () -> Void) {
    #if os(macOS)
        let requestFunc = requestWithURLSession
    #else
        let requestFunc = requestWithKitura
    #endif
    requestFunc(forURL: url) {
        data, repsonse, error in
        return
    }
}

/*func getCircuitStatusTimeout(forURL url: URL, response: RouterResponse, next: @escaping () -> Void) {
    print("Tick")
    let timeoutCallback = timeoutCallbackGenerator(response: response, next: next)
    #if os(macOS)
        let breaker = CircuitBreaker(timeout: 10, maxFailures: 1, fallback: timeoutCallback, command: requestWithURLSession)
    #else
        let breaker = CircuitBreaker(timeout: 10, maxFailures: 1, fallback: timeoutCallback, command: requestWithKitura)
    #endif
    breaker.run(args: (url: url, response: response, next: next))
}*/

func getCircuitStatus(forURL url: URL, response: RouterResponse, next: @escaping () -> Void) {
    
}
