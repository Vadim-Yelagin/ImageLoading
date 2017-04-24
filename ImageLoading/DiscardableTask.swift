//
//  DiscardableTask.swift
//
//  Created by Vadim Yelagin on 19/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation

public enum DiscardableTaskState<T> {
	case undefined
	case loading
	case success(result: T)
	case failure(error: Error)
}

public final class DiscardableTask<T>: InUseReporting {
	public typealias State = DiscardableTaskState<T>

	private var observers: [Int: (State) -> ()] = [:]
	private var observerCounter = 0

	public var cancel: (() -> ())?
	public var retry: (() -> ())?
	public var state = State.undefined {
		didSet {
			self.observers.values.forEach { $0(state) }
		}
	}

	public var isInUse: Bool {
		return !self.observers.isEmpty
	}

	public var isUndefinedOrFailed: Bool {
		switch self.state {
		case .undefined, .failure:
			return true
		case .loading, .success:
			return false
		}
	}

	public func observe(_ observer: @escaping (State) -> ()) -> () -> () {
		self.retry?()
		observer(self.state)
		let idx = self.observerCounter
		self.observerCounter += 1
		self.observers[idx] = observer
		return { [weak self] in self?.unobserve(idx) }
	}

	private func unobserve(_ idx: Int) {
		self.observers[idx] = nil
		if self.observers.isEmpty {
			self.cancel?()
		}
	}

	deinit {
		self.cancel?()
	}
}
