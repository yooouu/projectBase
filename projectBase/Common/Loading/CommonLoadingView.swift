//
//  CommonLoadingView.swift
//  projectBase
//
//  Created by 유영문 on 2020/09/08.
//  Copyright © 2020 유영문. All rights reserved.
//

import UIKit

class CommonLoading {
    static let shared: CommonLoading = {
        return CommonLoading()
    }()
    
    fileprivate let commonLoadingView: CommonLoadingView
    fileprivate let rotationAnimation: CABasicAnimation = {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        return rotation
    }()
    var count: Int = 0
    
    private init() {
        let loading = CommonLoadingView(frame: .zero)
        self.commonLoadingView = loading
    }
    
    func show(_ superView: UIWindow) {
        let task: () -> () = {
            self.commonLoadingView.frame = UIScreen.main.bounds
            superView.addSubview(self.commonLoadingView)
            
            self.commonLoadingView.loadingImage.layer.add(self.rotationAnimation, forKey: "rotationAnimation")
            self.count += 1
        }
        
        if Thread.isMainThread {
            task()
        } else {
            DispatchQueue.main.async {
                task()
            }
        }
    }
    
    func hide() {
        let task: () -> () = {
            if self.count > 0 {
                self.count -= 1
            } else {
                self.count = 0
            }
            
            if self.count == 0 {
                self.commonLoadingView.loadingImage.layer.removeAllAnimations()
                self.commonLoadingView.removeFromSuperview()
            }
        }
        
        if Thread.isMainThread {
            task()
        } else {
            DispatchQueue.main.async {
                task()
            }
        }
    }
}

class CommonLoadingView: UIView {
    private var contentView: UIView?
    @IBOutlet var loadingImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    fileprivate func initialize() {
        guard let xib = Bundle.main.loadNibNamed("CommonLoginView", owner: self, options: nil)?.first as? UIView else {
            return
        }
        self.addSubview(xib)
        contentView = xib
        
        xib.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            xib.topAnchor.constraint(equalTo: self.topAnchor),
            xib.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            xib.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            xib.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
