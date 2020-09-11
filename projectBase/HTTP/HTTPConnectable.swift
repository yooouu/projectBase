//
//  HTTPConnectable.swift
//  projectBase
//
//  Created by 유영문 on 2020/09/07.
//  Copyright © 2020 유영문. All rights reserved.
//

import Foundation

protocol HTTPResponsable {
    init?(response r: HTTPURLResponse?, data d: Data)
}

extension HTTPResponsable {
    static func initialize<T>(response r: HTTPURLResponse?, data d: Data) -> T? where T: HTTPResponsable {
        return T.init(response: r, data: d)
    }
}

struct DataResponse: HTTPResponsable {
    let response: HTTPURLResponse?
    let data: Data
}

struct JsonResponse: HTTPResponsable {
    let response: HTTPURLResponse?
    let data: Dictionary<String, Any>
    
    init?(response r: HTTPURLResponse?, data d: Data) {
        self.response = r
        do {
            guard let result = try JSONSerialization.jsonObject(with: d, options: .mutableContainers) as? [String: Any] else {
                return nil
            }
            
            self.data = result
            
        } catch {
            return nil
        }
    }
}

// EUC_KR
struct EucKrResponse: HTTPResponsable {
    let response: HTTPURLResponse?
    let data: String
    
    init?(response r: HTTPURLResponse?, data d: Data) {
        guard let decodedData = DataUtil.decodeEUC_KR(d) else { return nil }
        self.data = decodedData
        self.response = r
    }
}

enum ConnectionStatus: UInt8 {
    case ready=0, done, connecting, fail, disable
    
    var isEnabled: Bool {
        switch self {
        case .ready, .fail:
            return true
        default:
            return false
        }
    }
}

struct FailResponse {
    let response: HTTPURLResponse?
    let error: Error?
    let errMsg: String
    let errorCode: String?
}

typealias onFail = ((FailResponse) -> Void)

protocol HTTPConnectable: class {
    var status : ConnectionStatus { get set }
    var sharedSession: URLSession { get }
}

extension HTTPConnectable {
    var sharedSession: URLSession {
        return SessionManager.shared.session
    }
    
    
    // MARK: -
    func load<T>(session: URLSession? = nil,
                 url: String,
                 errorHandler: onFail? = nil,
                 completionHandler: ((T) -> ())? = nil) where T: HTTPResponsable {
        guard let request = DataUtil.toRequest(url) else {
            self.error(errorHandler: errorHandler, response: nil, error: nil, errMsg: "LocalizedKeySet.invalid_url.rawValue")
            return
        }
        
        self.load(session: session, request: request, errorHandler: errorHandler, completionHandler: completionHandler)
    }
    
    func load<T>(session: URLSession? = nil,
                 request: URLRequest,
                 errorHandler: onFail? = nil,
                 completionHandler: ((T) -> ())? = nil) where T: HTTPResponsable {
        
        status = .connecting
        
        let _session = session ?? self.sharedSession
        let task = _session.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            print("\(httpResponse?.statusCode ?? 0) : \(request.url?.absoluteString ?? "")")
            
            guard error == nil else {
                print("on url: \(String(describing: request.url?.absoluteString)) desc: \(String(describing: error))")
                self.error(errorHandler: errorHandler, response: httpResponse, error: error, errMsg: SessionManager.shared.getRequestErrorMessage(response: httpResponse) ?? error?.localizedDescription)
                return
            }
            
            if let errMsg = SessionManager.shared.getRequestErrorMessage(response: httpResponse) {
                print("on url: \(String(describing: request.url?.absoluteString)) desc: \(String(describing: errMsg))")
                self.error(errorHandler: errorHandler, response: httpResponse, error: error, errMsg: errMsg)
                return
            }
            
            guard let responseData = data else {
                self.error(errorHandler: errorHandler, response: httpResponse, error: error, errMsg: "not_found_data.localized")
                return
            }
            
            guard let callbackClosure: T = T.initialize(response: httpResponse, data: responseData) else {
                self.error(errorHandler: errorHandler, response: httpResponse, error: error, errMsg: "LocalizedKeySet.not_found_data.localized")
                return
            }
            
            completionHandler?(callbackClosure)
            self.status = .done
        }
        
        task.resume()
    }
    
    fileprivate func error(errorHandler: (onFail?), response: HTTPURLResponse?, error: Error?, errMsg: String?, errorCode: String? = nil) {
        self.status = .fail
        
        if let errorHandler = errorHandler {
            let callback = FailResponse(response: response, error: error, errMsg: errMsg ?? ".lost_network_connection", errorCode: errorCode)
            errorHandler(callback)
            
        } else {
            // TO DO : ToastView
        }
    }
}
