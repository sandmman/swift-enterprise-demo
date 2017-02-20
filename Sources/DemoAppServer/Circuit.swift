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
        sendCircuitStatus(state: .halfopen)
    case BreakerError.fastFail:
        sendCircuitStatus(state: .closed)
    }
}

func circuitRequestWrapper(invocation: Invocation<(URL), Void>) {
    let url: URL = invocation.args
    let callback = { (data: Data?, restResponse: URLResponse?, error: Swift.Error?) -> Void in
        guard error == nil else {
            //response.status(.internalServerError).send("Could not parse server response.")
            //next()
            invocation.notifyFailure()
            return
        }
        
        guard let httpResponse = restResponse as? HTTPURLResponse else {
            //response.status(.internalServerError).send("Could not parse server response.")
            //next()
            invocation.notifyFailure()
            return
        }
        
        if httpResponse.statusCode == 200 {
            //let _ = response.send(status: .OK)
            //next()
            invocation.notifySuccess()
            sendCircuitStatus(state: .closed)
        } else {
            //let _ = response.send(status: .expectationFailed)
            //next()
            invocation.notifyFailure()
        }
    }
    networkRequest(url: url, method: "GET", callback: callback)
}

func sendCircuitStatus(state: State) {
    switch state {
    case .open:
        break
    case .halfopen:
        break
    case .closed:
        break
    }
}
