//
//  DiscardableTask.swift
//
//  Created by Vadim Yelagin on 19/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation

public enum DiscardableTaskState<T, E> {
	case undefined
	case loading
	case success(result: T)
	case failure(error: E)
}

public final class DiscardableTask<T, E>: InUseReporting {

	fileprivate var observers: [Int: (DiscardableTaskState<T, E>) -> Void] = [:]
	fileprivate var observerCounter = 0

	public func observe(_ observer: @escaping (DiscardableTaskState<T, E>) -> Void) -> () -> () {
		self.retry?()
		observer(state)
		let idx = observerCounter
		observerCounter += 1
		observers[idx] = observer
		return { [weak self] in self?.unobserve(idx) }
	}

	fileprivate func unobserve(_ idx: Int) {
		self.observers[idx] = nil
		if self.observers.isEmpty {
			self.cancel?()
		}
	}

	public var state: DiscardableTaskState<T, E> = .undefined {
		didSet {
			for (_, observer) in observers {
				observer(state)
			}
		}
	}

	public var isUndefinedOrFailed: Bool {
		switch state {
		case .undefined:
			return true
		case .failure:
			return true
		case .loading:
			return false
		case .success:
			return false
		}
	}

	public var cancel: ((Void) -> Void)?

	public var retry: ((Void) -> Void)?

	deinit {
		self.cancel?()
	}

	public var isInUse: Bool {
		return !observers.isEmpty
	}
	
}
