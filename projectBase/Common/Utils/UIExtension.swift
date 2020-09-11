//
//  UIExtension.swift
//  projectBase
//
//  Created by 유영문 on 2020/09/07.
//  Copyright © 2020 유영문. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localizedWithComment(_ comment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
    
    func indexOf(_ text: String) -> Int {
        let range: NSRange? = (self as NSString).range(of: text)
        if let range = range, range.length > 0 {
            return range.location
        }
        
        return -1
    }
    
    func queryData(decoding: Bool) -> Dictionary<String, Any>? {
        var components = URLComponents()
        var data = Dictionary<String, Any>()
        components.query = self
        if let items = components.queryItems {
            for item in items {
                guard let value = item.value else { continue }
                let key = decoding ? (item.name.removingPercentEncoding ?? item.name): item.name
                data[key] = decoding ? (value.removingPercentEncoding ?? value) : value
            }
        }
        
        return data.isEmpty ? nil : data
    }
}

extension Dictionary {
    mutating func update(other: Dictionary) {
        for (key, value) in other {
            self.updateValue(value, forKey:key)
        }
    }
    
    func queryString(encoding: Bool = true) -> String? {
        guard self.count > 0  else { return nil }
        var components = URLComponents()
        var queryItems = Array<URLQueryItem>()
        
        if let queryData = self as? Dictionary<String, Any?> {
            for (key, value) in queryData {
                guard let _value = value else { continue }
                switch _value {
                case is String, is Int, is Bool, is Double, is Float, is NSNumber, is NSString:
                    if encoding {
                        queryItems.append(URLQueryItem(name: DataUtil.encodeUrl(key), value: DataUtil.encodeUrl(DataUtil.toString(_value) )))
                    } else {
                        queryItems.append(URLQueryItem(name: key, value: DataUtil.toString(_value)))
                    }
                    
                default:
                    break
                }
            }
            
            components.queryItems = queryItems
            return components.query
        }
        
        return nil
    }
}

extension UIView {
    @IBInspectable var borderWitdh: CGFloat {
        get {
            return 0.0
        }
        set {
            layer.borderWidth = newValue
        }
    }
    @IBInspectable var borderColor: UIColor {
        get {
            return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    var viewTag: ViewTag? {
        return ViewTag(rawValue: self.tag)
    }
    
    func viewWithViewTag(_ tag: ViewTag) -> UIView? {
        return self.viewWithTag(tag.rawValue)
    }
}

extension UIButton {
    func roundCorners(corners: UIRectCorner, radius: CGFloat, btnColor: CGColor) {
        let borderLayer = CAShapeLayer()
        borderLayer.frame = self.layer.bounds
        borderLayer.fillColor = btnColor
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        borderLayer.path = path.cgPath
        self.layer.addSublayer(borderLayer)
    }
    
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
}

extension UIImageView {
    func downloaded(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        contentMode = .scaleAspectFit
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async {
                self.image = image
            }
            }.resume()
    }
}

extension UIImage {
    // Image size가 1024x1024가 넘어갈경우 Resizing 처리
    func resizeImage() -> UIImage {
        // 1024x1024 이상일 경우
        if self.size.width >= 1024 && self.size.height >= 1024 {
            UIGraphicsBeginImageContext(CGSize(width: 1024, height: 1024))
            self.draw(in: CGRect(x: 0, y: 0, width: 1024, height: 1024))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        // height가 1024 이상일 경우
        } else if self.size.width < 1024 && self.size.height >= 1024 {
            UIGraphicsBeginImageContext(CGSize(width: self.size.width, height: 1024))
            self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: 1024))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        // width가 1024 이상일 경우
        } else if self.size.width >= 1024 && self.size.height < 1024 {
            UIGraphicsBeginImageContext(CGSize(width: 1024, height: self.size.height))
            self.draw(in: CGRect(x: 0, y: 0, width: 1024, height: self.size.height))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
            
        } else {
            return self
        }
    }
    
    // Resizes an input image (self) to a specified size
    func resizeToSize(size: CGSize) -> UIImage? {
        // Begins an image context with the specified size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        // Draws the input image (self) in the specified size
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        // Gets an UIImage from the image context
        let result = UIGraphicsGetImageFromCurrentImageContext()
        // Ends the image context
        UIGraphicsEndImageContext();
        // Returns the final image, or NULL on error
        return result;
    }
    
    // Crops an input image (self) to a specified rect
    func cropToRect(rect: CGRect) -> UIImage? {
        // Correct rect size based on the device screen scale
        let scaledRect = CGRect(x: rect.origin.x * self.scale, y: rect.origin.y * self.scale, width: rect.size.width * self.scale, height: rect.size.height * self.scale);
        // New CGImage reference based on the input image (self) and the specified rect
        let imageRef = self.cgImage!.cropping(to: scaledRect);
        // Gets an UIImage from the CGImage
        let result = UIImage(cgImage: imageRef!, scale: 1.0, orientation: self.imageOrientation)
        // Returns the final image, or NULL on error
        return result;
    }

}

@IBDesignable
extension UITextField {
    
    @IBInspectable var paddingLeftCustom: CGFloat {
        get {
            return leftView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            leftView = paddingView
            leftViewMode = .always
        }
    }
    
    @IBInspectable var paddingRightCustom: CGFloat {
        get {
            return rightView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            rightView = paddingView
            rightViewMode = .always
        }
    }
}

extension UIDevice {
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String {
            #if os(iOS)
            switch identifier {
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "i386", "x86_64":                          return "\(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
}
