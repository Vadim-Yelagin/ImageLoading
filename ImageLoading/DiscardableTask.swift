//
//  DiscardableTask.swift
//
//  Created by Vadim Yelagin on 19/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation

public enum DiscardableTaskState<T, E> {
	case Undefined
	case Loading
	case Success(result: T)
	case Failure(error: E)
}

public final class DiscardableTask<T, E>: InUseReporting {

	private var observers: [Int: DiscardableTaskState<T, E> -> Void] = [:]
	private var observerCounter = 0

	public func observe(observer: DiscardableTaskState<T, E> -> Void) -> () -> () {
		self.retry?()
		observer(state)
		let idx = observerCounter++
		observers[idx] = observer
		return { [weak self] in self?.unobserve(idx) }
	}

	private func unobserve(idx: Int) {
		self.observers[idx] = nil
		if self.observers.isEmpty {
			self.cancel?()
		}
	}

	public var state: DiscardableTaskState<T, E> = .Undefined {
		didSet {
			for (_, observer) in observers {
				observer(state)
			}
		}
	}

	public var isUndefinedOrFailed: Bool {
		switch state {
		case .Undefined:
			return true
		case .Failure:
			return true
		case .Loading:
			return false
		case .Success:
			return false
		}
	}

	public var cancel: (Void -> Void)?

	public var retry: (Void -> Void)?

	deinit {
		self.cancel?()
	}

	public var isInUse: Bool {
		return !observers.isEmpty
	}
	
}
