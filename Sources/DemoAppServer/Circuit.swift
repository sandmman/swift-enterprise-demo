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

enum CircuitError: Swift.Error {
    case BadURL
}

func timeoutCallbackGenerator(response: RouterResponse, next: @escaping () -> Void) -> (BreakerError) -> Void {
    return { err in
        print("Failed")
        switch err {
        case BreakerError.timeout:
            response.status(.expectationFailed).send("Operation timed out. Circuit open.")
        case BreakerError.fastFail:
            response.status(.expectationFailed).send("Coudl not reach URL. Circuit open.")
        }
        next()
    }
}

func requestWrapper(invocation: Invocation<(URL, RouterResponse, () -> Void), Void>) {
    let url: URL = invocation.args.0
    let response: RouterResponse = invocation.args.1
    let next: () -> Void = invocation.args.2
    let callback = { (data: Data?, restResponse: URLResponse?, error: Swift.Error?) -> Void in
        print("\(restResponse)")
        guard error != nil else {
            response.status(.internalServerError).send("Could not parse server response.")
            next()
            invocation.notifyFailure()
            return
        }
        
        guard let httpResponse = restResponse as? HTTPURLResponse else {
            response.status(.internalServerError).send("Could not parse server response.")
            next()
            invocation.notifyFailure()
            return
        }
        
        if httpResponse.statusCode == 200 {
            response.status(.OK).send("Circuit closed.")
            next()
            invocation.notifySuccess()
        } else {
            invocation.notifyFailure()
        }
    }
    networkRequest(url: url, method: "GET", callback: callback)
}

func getCircuitStatus(forURL url: URL, response: RouterResponse, next: @escaping () -> Void) {
    let timeoutCallback = timeoutCallbackGenerator(response: response, next: next)
    let breaker = CircuitBreaker(timeout: 10, maxFailures: 1, fallback: timeoutCallback, commandWrapper: requestWrapper)
    breaker.run(args: (url: url, response: response, next: next))
}
