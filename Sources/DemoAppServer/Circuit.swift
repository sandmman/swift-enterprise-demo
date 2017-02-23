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

func circuitTimeoutCallback(_ err: BreakerError, _ fallbackArgs: (response: RouterResponse, next: () -> Void)) {
    let response: RouterResponse = fallbackArgs.0
    let next: () -> Void = fallbackArgs.1
    switch err {
    case BreakerError.timeout:
        response.status(.expectationFailed).send("Request timed out.")
        next()
        break
    case BreakerError.fastFail:
        response.status(.expectationFailed).send("Request failed fast.")
        next()
        break
    }
}

func circuitRequestWrapper(invocation: Invocation<(URL, RouterResponse, () -> Void), Void, (RouterResponse, () -> Void)>) {
    let url: URL = invocation.commandArgs.0
    let response: RouterResponse = invocation.commandArgs.1
    let next: () -> Void = invocation.commandArgs.2
    let callback = { (restData: Data?, restResponse: URLResponse?, error: Swift.Error?) -> Void in
        guard error == nil, let data = restData else {
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
            let _ = response.status(.OK).send(data: data)
            next()
            invocation.notifySuccess()
        } else {
            let _ = response.send(status: .expectationFailed)
            next()
            invocation.notifyFailure()
        }
    }
    networkRequest(url: url, method: "GET", callback: callback)
}

func broadcastCircuitStatus(breaker: CircuitBreaker<(URL, RouterResponse, () -> Void), Void, (RouterResponse, () -> Void)>) {
    let state = breaker.breakerState
    for (_, connection) in controller.wsConnections {
        switch state {
        case .open:
            connection.send(message: "open")
        case .halfopen:
            connection.send(message: "half-open")
        case .closed:
            connection.send(message: "closed")
        }
    }
}
