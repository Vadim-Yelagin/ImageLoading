//
//  Cache.swift
//
//  Created by Vadim Yelagin on 19/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation
import UIKit

public protocol InUseReporting: class {
	var isInUse: Bool { get }
}

public final class Cache<K: Hashable, V: InUseReporting> {
	public var storage = [K: V]()
	private var notificationObservers = [NSObjectProtocol]()

	public func purge() {
		for (key, value) in self.storage {
			if !value.isInUse {
				self.storage[key] = nil
			}
		}
	}

	public init() {
		let nc = NotificationCenter.default
		let purgingNotificationNames = [
			NSNotification.Name.UIApplicationDidEnterBackground,
			NSNotification.Name.UIApplicationDidReceiveMemoryWarning]
		for name in purgingNotificationNames {
			self.notificationObservers.append(
				nc.addObserver(forName: name, object: nil, queue: .main) {
					[weak self] _ in self?.purge()
				})
		}
	}

	deinit {
		let nc = NotificationCenter.default
		for notificationObserver in self.notificationObservers {
			nc.removeObserver(notificationObserver)
		}
	}
}
