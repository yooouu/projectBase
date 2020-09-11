//
//  SessionManager.swift
//  projectBase
//
//  Created by 유영문 on 2020/09/07.
//  Copyright © 2020 유영문. All rights reserved.
//

import Foundation

public let REQUEST_TIMEOUT = TimeInterval(10)
public let RESOURCE_TIMEOUT = TimeInterval(10)

class SessionManager {
    fileprivate var sessionConfiguration: URLSessionConfiguration!
    let sessionConfigurationHeaders: Dictionary<String, Any>
    
    static let shared: SessionManager = {
        let instance = SessionManager()
        return instance
    }()
    
    private init() {
        sessionConfigurationHeaders = [
            "cHeader": "os=ios;"
        ]
    }
    
    var session: URLSession {
        return URLSession(configuration: sessionConfigure)
    }
    
    fileprivate var sessionConfigure: URLSessionConfiguration {
        if sessionConfiguration == nil {
            sessionConfiguration = URLSessionConfiguration.default
            
            sessionConfiguration.httpAdditionalHeaders = sessionConfigurationHeaders
            
            sessionConfiguration.urlCache = nil
            sessionConfiguration.urlCredentialStorage = nil
            sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
            sessionConfiguration.timeoutIntervalForRequest = REQUEST_TIMEOUT
            sessionConfiguration.timeoutIntervalForResource = RESOURCE_TIMEOUT
        }
        
        return sessionConfiguration
    }
    
    public func getDefaultConfiguration() -> URLSessionConfiguration {
        let configure = URLSessionConfiguration.default
        configure.httpAdditionalHeaders = sessionConfigurationHeaders
        configure.urlCache = nil
        configure.urlCredentialStorage = nil
        configure.requestCachePolicy = .reloadIgnoringLocalCacheData
        configure.timeoutIntervalForRequest = REQUEST_TIMEOUT
        configure.timeoutIntervalForResource = RESOURCE_TIMEOUT
        return configure
    }
    
    public func getRequestErrorMessage(response: HTTPURLResponse?) -> String? {
        let code = response?.statusCode ?? 0
        guard !(200...299 ~= code) else { return nil }
        
        var errorMessage: String? = nil
        
        switch code {
        case 404:
            errorMessage = "http_not_found_page_error"
        case 501:
            errorMessage = "http_internal_server_error"
        case 503:
            errorMessage = "http_service_unabailable_error"
        default:
            if code >= 500 {
                errorMessage = "http_server_error"
            } else if code == -1009 {
                errorMessage = "lost_network_connection"
            }
        }
        
        return errorMessage
    }
}
