//
//  LoginData.swift
//  projectBase
//
//  Created by 유영문 on 2020/09/07.
//  Copyright © 2020 유영문. All rights reserved.
//

import Foundation

struct LoginData: Codable {
    var userId: Int?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
    }
}
