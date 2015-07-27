//
//  Cache.swift
//
//  Created by Vadim Yelagin on 19/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation
import UIKit

public protocol InUseReporting: AnyObject {
    
    var isInUse: Bool { get }
    
}

public final class Cache<K: Hashable, V: InUseReporting> {
    
    public var storage = [K: V]()
    
    public func purge() {
        for (key, value) in storage {
            if !value.isInUse {
                storage[key] = nil
            }
        }
    }
    
    private var notificationObservers = [NSObjectProtocol]()
    
    public init() {
        let nc = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        let purgingNotificationNames = [
            UIApplicationDidEnterBackgroundNotification,
            UIApplicationDidReceiveMemoryWarningNotification]
        for name in purgingNotificationNames {
            notificationObservers.append(
                nc.addObserverForName(name, object: nil, queue: mainQueue) {
                    [weak self] _ in self?.purge()
                })
        }
    }
    
    deinit {
        let nc = NSNotificationCenter.defaultCenter()
        for notificationObserver in notificationObservers {
            nc.removeObserver(notificationObserver)
        }
    }
    
}
