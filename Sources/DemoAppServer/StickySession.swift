//
//  StickySession.swift
//  SwiftEnterpriseDemo
//
//  Created by Jim Avery on 3/9/17.
//
//

import Kitura
import Foundation
import Configuration
import CloudFoundryEnv
import CloudFoundryConfig

class StickySession: RouterMiddleware {
    let JSESSIONID: String?
    
    init(withConfigMgr configMgr: ConfigurationManager) {
        if configMgr.isLocal == false, let appData = configMgr.getApp() {
            self.JSESSIONID = "\(appData.instanceIndex)"
        } else {
            self.JSESSIONID = nil
        }
    }
    
    func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let sessionID = self.JSESSIONID else {
            next()
            return
        }
        
        var properties: [HTTPCookiePropertyKey: Any] = [:]
        properties[HTTPCookiePropertyKey.name] = "JSESSIONID"
        properties[HTTPCookiePropertyKey.value] = sessionID
        properties[HTTPCookiePropertyKey.path] = "/"
        properties[HTTPCookiePropertyKey.originURL] = request.urlURL
        if let stickyCookie = HTTPCookie(properties: properties) {
            response.cookies["JSESSIONID"] = stickyCookie
        }
        next()
    }
}
