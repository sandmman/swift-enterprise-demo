//
//  Circuit.swift
//  SwiftEnterpriseDemo
//
//  Created by Jim Avery on 2/13/17.
//
//

import Foundation
import Kitura
import CircuitBreaker

func timeoutCallbackGenerator(response: RouterResponse, next: @escaping () -> Void) -> (BreakerError) -> Void {
    return { err in
        switch err {
        case BreakerError.timeout:
            response.status(.internalServerError).send("Operation timed out. Circuit open.")
        case BreakerError.fastFail:
            response.status(.internalServerError).send("Circuit open.")
        }
        next()
    }
}

func requestWithURLSession(url: URL) {
    guard let circuitURL = URL(string: "/json", relativeTo: url) else {
        response.status(.badRequest).send("Bad URL sent. Cannot report circuit status.")
        next()
        return
    }
}

func requestWithKitura(url: URL) {
    
}

func getCircuitStatus(forURL url: URL, response: RouterResponse, next: @escaping () -> Void) {
    let timeoutCallback = timeoutCallbackGenerator(response: response, next: next)
    #if os(macOS)
        let breaker = CircuitBreaker(timeout: 10, maxFailures: 1, fallback: timeoutCallback, command: requestWithURLSession)
    #else
        let breaker = CircuitBreaker(timeout: 10, maxFailures: 1, fallback: timeoutCallback, command: requestWithKitura)
    #endif
    breaker.run(args: (url: url))
}
