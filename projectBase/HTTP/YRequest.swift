//
//  YRequest.swift
//  projectBase
//
//  Created by 유영문 on 2020/09/07.
//  Copyright © 2020 유영문. All rights reserved.
//

import Foundation
import UIKit

class YRequest: NSObject, HTTPConnectable {
    
    static let shared = YRequest()
    var status: ConnectionStatus = .ready
    
    // MARK: - Requests
    public func userLogin(_ id: String, _ pw: String, handler: @escaping ((LoginData?, String?) -> Void)) {
        let data: Dictionary<String, Any> = [ID : id,
                                             PASSWORD : pw]
        guard let request = DataUtil.toRequestWithFormData("\(IP)\(USER_LOGIN)", data: data) else { return }
        
        sendRequest(request, YResponse<LoginData>.self, handler: handler)
    }
    
    // MARK: - Send Request
    private func sendRequest<T: Codable>(_ request: URLRequest, _ model: YResponse<T>.Type, handler: @escaping ((T?, String?) -> Void)) {
        load(request: request, errorHandler: { (fail) in
            handler(nil, fail.errMsg)
            
        }) { (callback: DataResponse) in
            let response = self.useDecodable(model: model, response: callback)
            
            if let result = response?.result {
                if result {
                    handler(response?.data, nil)
                } else {
                    handler(nil, response?.error)
                }
            } else {
                handler(nil, "result data nil...")
            }
        }
    }
    
    // MARK: - Decode Response Data
    func useDecodable<T: Codable>(model: T.Type, response: DataResponse) -> T? {
        do {
            let data = try JSONDecoder().decode(model, from: response.data)
            return data
        } catch {
            print("decode error : \(error.localizedDescription)")
            return nil
        }
    }
}
