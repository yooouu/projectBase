//
//  Constants.swift
//  projectBase
//
//  Created by 유영문 on 2020/09/07.
//  Copyright © 2020 유영문. All rights reserved.
//

import Foundation

#if DEBUG
public let IP: String = "http://211.218.126.231"   // Test Server
#else
public let IP: String = "https://www.test.co.kr"  // Real Server
#endif

//MARK: - UIButton naming
enum ViewTag: Int {
    case login_button                =   100001
}

// MARK: - api url
public let USER_LOGIN: String = "/app/user/login"

// MARK: - Parameters
public let TYPE: String = "type"

// MARK: - Key String
public let ID: String = "id"
public let PASSWORD: String = "password"
public let FCM_TOKEN: String = "fcm_token"
public let RESULT: String = "result"
public let TRUE: String = "true"
public let FALSE: String = "false"
public let DATA: String = "data"
public let TITLE: String = "title"
public let NAME: String = "name"
