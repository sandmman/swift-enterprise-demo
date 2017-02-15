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
            response.status(.internalServerError).send("Operation timed out. Circuit open.")
        case BreakerError.fastFail:
            response.status(.internalServerError).send("Circuit open.")
        }
        next()
    }
}

func requestWrapper(invocation: Invocation<(URL, RouterResponse, () -> Void), Void>) {
//func requestWrapper(forURL url: URL, response: RouterResponse, next: @escaping () -> Void) {
    let url: URL = invocation.args.0
    let response: RouterResponse = invocation.args.1
    let next: () -> Void = invocation.args.2
    let callback = { (data: Data?, restResponse: URLResponse?, error: Swift.Error?) -> Void in
        if error == nil {
            response.status(.internalServerError).send("Could not reach URL. Circuit open.")
            next()
            invocation.notifyFailure()
        } else {
            response.status(.OK).send("Circuit closed.")
            next()
            invocation.notifySuccess()
        }
    }
    #if os(macOS)
        requestWithURLSession(url: url, callback: callback)
    #else
        requestWithKitura()
    #endif
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
    let timeoutCallback = timeoutCallbackGenerator(response: response, next: next)
    let breaker = CircuitBreaker(timeout: 10, maxFailures: 1, fallback: timeoutCallback, commandWrapper: requestWrapper)
    breaker.run(args: (url: url, response: response, next: next))
}
