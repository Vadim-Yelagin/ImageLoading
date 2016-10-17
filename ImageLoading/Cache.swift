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

	fileprivate var notificationObservers = [NSObjectProtocol]()

	public init() {
		let nc = NotificationCenter.default
		let mainQueue = OperationQueue.main
		let purgingNotificationNames = [
			NSNotification.Name.UIApplicationDidEnterBackground,
			NSNotification.Name.UIApplicationDidReceiveMemoryWarning]
		for name in purgingNotificationNames {
			notificationObservers.append(
				nc.addObserver(forName: name, object: nil, queue: mainQueue) {
					[weak self] _ in self?.purge()
				})
		}
	}

	deinit {
		let nc = NotificationCenter.default
		for notificationObserver in notificationObservers {
			nc.removeObserver(notificationObserver)
		}
	}
	
}
