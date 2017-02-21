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

func circuitTimeoutCallback(err: BreakerError) {
    switch err {
    case BreakerError.timeout:
        break
    case BreakerError.fastFail:
        break
    }
}

func circuitRequestWrapper(invocation: Invocation<(URL, RouterResponse, () -> Void), Void>) {
    let url: URL = invocation.args.0
    let response: RouterResponse = invocation.args.1
    let next: () -> Void = invocation.args.2
    let callback = { (data: Data?, restResponse: URLResponse?, error: Swift.Error?) -> Void in
        guard error == nil else {
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
            let _ = response.send(status: .OK)
            next()
            invocation.notifySuccess()
        } else {
            let _ = response.send(status: .expectationFailed)
            next()
            invocation.notifyFailure()
        }
    }
    networkRequest(url: url, method: "GET", callback: callback)
    broadcastCircuitStatus(breaker: controller.breaker)
}

func broadcastCircuitStatus(breaker: CircuitBreaker<(URL, RouterResponse, () -> Void), Void>) {
    //let state = breaker.breakerState
    let state: State = .closed
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
