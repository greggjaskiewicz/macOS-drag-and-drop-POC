//
//  DataChangedObserver.swift
//
//  Created by Gregg Jaskiewicz on 16/11/2017.
//  Copyright © 2017 k4lab. All rights reserved.
//

import Foundation

@objc final class DataChangedNotifier: NSObject {
    @objc static func notify(dataType: String) {
        NotifyDataChanged(dataType: dataType)
    }
}

func NotifyDataChanged(dataType: String) {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: dataType), object: nil)
}

func NotifyDataChangedWithUserdata(dataType: String, userData: [AnyHashable:Any]) {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: dataType), object: nil, userInfo: userData)
}

@objc final class DataChangedObserver: NSObject {

    fileprivate let dataType: String

    init(dataType: String) {
        self.dataType = dataType
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func changeObserver(_ completionBlock: @escaping (() -> Void)) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: self.dataType),
                                               object: nil,
                                               queue: OperationQueue.main) { (_) in
                                                completionBlock()
        }
    }

    @objc func changeObserverWithUserData(_ completionBlock: @escaping ((_ userData: [AnyHashable:Any]? ) -> Void)) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: self.dataType),
                                               object: nil,
                                               queue: OperationQueue.main) { (notification) in
                                                let userInfo = notification.userInfo
                                                completionBlock(userInfo)
        }
    }
}

