//
//  DataUtil.swift
//  projectBase
//
//  Created by 유영문 on 2020/09/07.
//  Copyright © 2020 유영문. All rights reserved.
//

import Foundation

class DataUtil {
    private init() {}
    
    class func toBool<T>(_ value: T?) -> Bool {
        let _value = DataUtil.toString(value)
        return _value == "1" || _value == "true"
    }
    
    class func toInteger<T>(_ value: T?, defaultValue: Int = 0) -> Int {
        return toIntegerNil(value) ?? defaultValue
    }
    
    class func toIntegerNil<T>(_ value: T?) -> Int? {
        guard let _value = value else { return nil }
        
        if let _v = _value as? Int {
            return _v
        } else if let _v = _value as? Double ?? Double(toString(_value)) {
            if Double(Int.max) >= _v {
                return Int(_v)  /* 소수점 버림 */
            }
        }
        
        return nil
    }
    
    class func toDouble<T>(_ value: T?, defaultValue: Double = 0) -> Double {
        return toDoubleNil(value) ?? defaultValue
    }
    
    class func toDoubleNil<T>(_ value: T?) -> Double? {
        guard let v = value else { return nil }
        
        if let _v = v as? Double {
            return _v
        } else if let _v = Double(toString(v)) {
            return _v
        }
        
        return nil
    }
    
    class func toStringNil<T>(_ value: T?) -> String? {
        guard let v = value else { return nil }
        
        switch v {
        case is String, is NSString:
            let _v = v as? String
            return (_v?.count ?? 0) > 0 ? _v : nil
        case  is Int, is Bool, is Double, is Float, is NSNumber:
            let _v = String(describing: v)
            if _v.count > 0 {
                return _v
            }
        default:
            break
        }
        
        return nil
    }
    
    class func toString<T>(_ value: T?, defaultValue: String = "") -> String {
        guard let v = value else { return defaultValue }
        switch v {
        case is String, is NSString:
            return v as? String ?? defaultValue
        case is Int, is Int8, is Int16, is Int32, is Int64, is UInt, is UInt8, is UInt16, is UInt32, is UInt64, is Bool, is Double, is Float, is NSNumber:
            return String(describing: v)
        case is Character:
            if let _v = v as? Character {
                return String(_v)
            }
        default:
            break
        }
        
        return defaultValue
    }
    
    struct KoreanCharacters {
        private init() {}
        static let shared: KoreanCharacters = {
            let instance = KoreanCharacters()
            return instance
        }()
        
        let INITIAL = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"];
        let MEDIAL = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", " ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"];
        let FINAL = [" ", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    }
    
    class func isEqualArray<T>(lhs: [T], rhs: [T]) -> Bool {
        guard lhs.count == rhs.count,
            {
                for (idx, value) in lhs.enumerated() {
                    if DataUtil.toString(value) != DataUtil.toString(rhs[idx]) {
                        return false
                    }
                }
                return true
            }()
            else { return false }
        return true
    }
    
    class func currentDate(_ dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let now = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ko_KR") as Locale
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: now as Date)
    }
    
    class var currentTime: UInt64 { // micro seconds
        return UInt64(NSDate().timeIntervalSince1970 * 1000)
    }
    
    class func validate(_ input: String?, regex: String?) -> Bool {
        guard let _regex = DataUtil.toStringNil(regex) else { return true }
        guard let _input = input else { return false }
        let predicate = NSPredicate(format: "SELF MATCHES %@", _regex)
        return predicate.evaluate(with: _input)
    }
    
    // HTTP URL UTIL
    class func base64Decoded(_ value: String) -> String? {
        if let data = Data(base64Encoded: value) {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
    class func toURL(_ url: String) -> URL? {
        guard url.count > 0 else { return nil }
        var _url = URL(string: url)
        if _url == nil {
            _url = URL(string: DataUtil.encodeUrl(url))
        }
        return _url
    }
    
    class func toRequest(_ url: String, timeout: TimeInterval = REQUEST_TIMEOUT, method: String = "GET") -> URLRequest? {
        guard let _url = toURL(url) else { return nil }
        var request = URLRequest(url: _url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        
        // TO DO setting default reuqest value
        for (key, value) in SessionManager.shared.sessionConfigurationHeaders {
            request.setValue(value as? String, forHTTPHeaderField: key)
        }
        
        request.httpMethod = method
        return request
    }
    
    class func toRequestWithJson(_ url: String, json: Dictionary<AnyHashable, Any>?) -> URLRequest? {
        guard let _url = toURL(url) else { return nil }
        var request = URLRequest(url: _url)
        var jsonBody: Data?
        
        if let _json = json {
            do {
                let __json = try JSONSerialization.data(withJSONObject: _json, options: [])
                jsonBody = String(data: __json, encoding: .utf8)?.data(using: .utf8)
                
            } catch let error {
                print(error)
            }
        }
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(jsonBody?.count ?? 0)", forHTTPHeaderField: "Content-Length")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 7.0
        request.httpBody = jsonBody
        
        for (key, value) in SessionManager.shared.sessionConfigurationHeaders {
            request.setValue(value as? String, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    class func toRequestWithFormData(_ url: String, data: Dictionary<AnyHashable, Any>?) -> URLRequest? {
        guard let _url = toURL(url) else { return nil }
        var request = URLRequest(url: _url)
        request.httpMethod = "POST"
        
        if let _data = data?.queryString()?.data(using: .ascii, allowLossyConversion: true) {
            request.setValue(DataUtil.toString(_data.count), forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            request.httpBody = _data
            
        } else {
            print("Encode Failed...")
        }
        
        return request
    }
    
    class func asUInt8FromHexString(_ str: String) -> UInt8 {
        var buffer : UInt64 = 0
        let scanner: Scanner = Scanner(string: str)
        if scanner.scanHexInt64(&buffer) {
            return UInt8(buffer)
        }
        
        return 0
    }
    
    // MARK : multipart request
    class func toRequestWithBody(_ url: String,  body: Dictionary<AnyHashable, Any>) -> URLRequest? {
        return self.toRequestWithBody(url, body: body, files: nil)
    }
    
    class func toRequestWithBody(_ url: String, body: Dictionary<AnyHashable, Any>, files: Array<Any>?) -> URLRequest? {
        guard let _url = toURL(url) else { return nil }
        var request = URLRequest(url: _url)
        var newBodyData = Data()
        var newBody = Dictionary<AnyHashable, Any>()
        var namedFiles = Array<Any>()
        var unnamedFiles = Array<Any>()
        let boundary = String(format: "%@_%d", "", _url.hashValue)
        
        //var queryString: String? = nil
        if let range = _url.absoluteString.range(of: "?") {
            if let query = String(_url.absoluteString[range.upperBound...]).queryData(decoding: true) {
                newBody.update(other: query)
            }
        }
        
        if body.isEmpty == false { newBody.update(other: body) }
        
        if let files = files {
            for newFile in files {
                guard let file = newFile as? Dictionary<String, Any>, file.count > 0 else { continue }
                
                if file["name"] != nil {
                    namedFiles.append(file)
                } else {
                    unnamedFiles.append(file)
                }
            }
        }
        
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        for (key, value) in newBody {
            if let newValue = value as? String {
                newBodyData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                newBodyData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(newValue)".data(using: .utf8)!)
            }
        }
        
        for newFile in namedFiles {
            guard let file = newFile as? Dictionary<String, Any>, file.count > 0 else { continue }
            
            let name = file["name"] as! String
            let fileName = file["fileName"] as! String
            let fileType = file["type"] != nil ? file["type"] as! String : "application/octet-stream"
            
            newBodyData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            newBodyData.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            newBodyData.append("Content-Type: \(fileType)\r\n\r\n".data(using: .utf8)!)
            newBodyData.append((file["data"] as! Data))
        }
        
        if unnamedFiles.count > 0 {
            newBodyData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            newBodyData.append("Content-Type: multipart/mixed; boundary=\(boundary)_FILE\r\n".data(using: .utf8)!)
            newBodyData.append("Content-Type: multipart/mixed; boundary=\(boundary)_FILE\r\n".data(using: .utf8)!)
            
            for newFile in unnamedFiles {
                let file = newFile as! Dictionary<String, Any>
                let fileName = file["fileName"] as! String
                let fileType = file["type"] != nil ? file["type"] as! String : "application/octet-stream"
                
                newBodyData.append("\r\n--\(boundary)_FILE\r\n".data(using: .utf8)!)
                newBodyData.append("Content-Disposition: file; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
                newBodyData.append("Content-Type: \(fileType)\r\n\r\n".data(using: .utf8)!)
                newBodyData.append((file["data"] as! Data))
            }
            
            newBodyData.append("\r\n--\(boundary)_FILE--\r\n".data(using: .utf8)!)
        }
        
        newBodyData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
//        request.httpMethod = "POST"
        request.httpMethod = "PUT"
        request.httpBody = newBodyData
        
        return request
    }
    
    class func appendingQuery(_ prefix: String, query: String?) -> String {
        if let query = query {
            return prefix.appendingFormat("%@%@", prefix.indexOf("?") > 0 ? "&" : "?", query)
        } else {
            return prefix
        }
    }
    
    class func addingPercentEncodingForRFC3986(_ value: String) -> String? {
        // Encoding for RFC 3986. Unreserved Characters: ALPHA / DIGIT / “-” / “.” / “_” / “~”
        // Section 3.4 also explains that since a query will often itself include a URL it is preferable to not percent encode the slash (“/”) and question mark (“?”).
        let unreserved = "-._~/?"
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: unreserved)
        return value.addingPercentEncoding(withAllowedCharacters: allowed)
    }
    
    class func addingPercentEncodingForFormData(_ value: String, plusForSpace: Bool = false) -> String? {
        // Encoding for x-www-form-urlencoded. Unreserved Characters: ALPHA / DIGIT / “*” / “-” / “.” / “_”
        let unreserved = "*-._"
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: unreserved)
        
        if plusForSpace {
            allowed.insert(charactersIn: " ")
            var encoded = value.addingPercentEncoding(withAllowedCharacters: allowed)
            encoded = encoded?.replacingOccurrences(of: " ", with: "+")
            return encoded
        } else {
            return value.addingPercentEncoding(withAllowedCharacters: allowed)
        }
    }
    
    class func encodeUrl(_ value: String) -> String {
        return DataUtil.addingPercentEncodingForRFC3986(value) ?? value
    }
    
    class func decodeUrl(_ value: String) -> String {
        return value.removingPercentEncoding ?? value
    }
    
    class func decodeEUC_KR(_ data: Data) -> String? {
        return String(
            bytes: data,
            encoding: String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_KR.rawValue)))
        )
    }
}
