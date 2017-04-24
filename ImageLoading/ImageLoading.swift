//
//  ImageLoading.swift
//
//  Created by Vadim Yelagin on 19/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation
import UIKit

public final class ImageLoading {
	public typealias Task = DiscardableTask<UIImage>

	public enum Error: Swift.Error, LocalizedError {
		case invalidFormat
		public var errorDescription: String? {
			return "Invalid image format"
		}
	}

	public static let shared = ImageLoading()

	private let cache = Cache<String, Task>()

	public func taskWithURL(_ url: URL) -> Task {
		return taskWithRequest(URLRequest(url: url))
	}

	public func taskWithRequest(_ request: URLRequest) -> Task {
		let url = request.url!.absoluteString
		if let task = self.cache.storage[url] {
			return task
		} else {
			let task = Task()
			task.retry = { [weak self, weak task] in
				if let this = self, let task = task, task.isUndefinedOrFailed {
					this.startTask(task, withRequest: request)
				}
			}
			self.cache.storage[url] = task
			return task
		}
	}

	public func cachedImageWithURLString(_ urlString: String?) -> UIImage? {
		if let urlString = urlString, let task = self.cache.storage[urlString] {
			switch task.state {
			case .success(let result):
				return result
			default:
				break
			}
		}
		return nil
	}

	private func startTask(_ task: Task, withRequest request: URLRequest) {
		task.state = .loading
		let op = URLSession.shared.dataTask(with: request) {
			[weak task] data, response, error in
			let state: Task.State
			if let error = error {
				if let error = error as? URLError, error.code == .cancelled {
					return
				}
				state = .failure(error: error)
			} else if let data = data, let image = UIImage(data: data) {
				state = .success(result: image)
			} else {
				state = .failure(error: Error.invalidFormat)
			}
			DispatchQueue.main.async {
				task?.state = state
				task?.cancel = nil
			}
		}
		task.cancel = { [weak op, weak task] in
			task?.state = .undefined
			op?.cancel()
		}
		op.resume()
	}
}
