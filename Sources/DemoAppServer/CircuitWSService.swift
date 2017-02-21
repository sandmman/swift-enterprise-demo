//
//  CircuitWSService.swift
//  SwiftEnterpriseDemo
//
//  Created by Jim Avery on 2/20/17.
//
//

import Foundation
import KituraWebSocket
import CircuitBreaker

class CircuitWSService: WebSocketService {
    public func connected(connection: WebSocketConnection) {
        controller.wsConnections[connection.id] = connection
    }
    
    public func disconnected(connection: WebSocketConnection, reason: WebSocketCloseReasonCode) {
        controller.wsConnections.removeValue(forKey: connection.id)
    }
    
    public func received(message: Data, from client: WebSocketConnection) {}
    
    public func received(message: String, from client: WebSocketConnection) {}
}
