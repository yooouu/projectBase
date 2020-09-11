//
//  BaseViewController.swift
//  projectBase
//
//  Created by 유영문 on 2020/09/07.
//  Copyright © 2020 유영문. All rights reserved.
//

import UIKit

typealias CallBackClosure = ((Any?) -> ())

class BaseViewController: UIViewController {
    var preparedData: [String : Any]?
    var nextPrepareData: [String : Any]?
    var callbackDataClosure: CallBackClosure? = nil
    var nextCallbackDataClosure: CallBackClosure? = nil
    
    fileprivate var timeStamp: UInt64 = 0
    var preventButtonClick: Bool {
        guard (DataUtil.currentTime - timeStamp) > 500 else { return false }
        timeStamp = DataUtil.currentTime
        return true
    }
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        // For navigation swipe back
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BaseViewController {
            if let next = nextPrepareData {     // 화면 이동 시 데이터 전달
                destination.preparedData = next
                nextPrepareData = nil
            }
            if let callback = nextCallbackDataClosure {     // 화면 되돌아왔을 경우 데이터 전달
                destination.callbackDataClosure = callback
                nextCallbackDataClosure = nil
            }
        }
        super.prepare(for: segue, sender: sender)
    }
    
    // MARK: - Loading
    func showLoading() {
        guard let window = UIApplication.shared.windows.first else { return }
        CommonLoading.shared.show(window)
    }
    
    func hideLoading() {
        CommonLoading.shared.hide()
    }
}

// MARK: - Extension AppStateDelegate
extension BaseViewController: AppStateDelegate {
    func applicationDidEnterBackground() { }
    
    func applicationDidBecomeActive() { }
    
    func applicationWillEnterForeground() { }
    
    func applicationWillTerminate() { }
}
