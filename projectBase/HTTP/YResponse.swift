//
//  YResponse.swift
//  projectBase
//
//  Created by 유영문 on 2020/09/07.
//  Copyright © 2020 유영문. All rights reserved.
//

import Foundation

struct YResponse<T: Codable>: Codable {
    var result: Bool?
    var data: T?
    var error: String?
    
    init(result: Bool = false, data: T?, error: String = "") {
        self.result = result
        self.data = data
        self.error = error
    }
}
