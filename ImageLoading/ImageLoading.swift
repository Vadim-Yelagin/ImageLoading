//
//  ImageLoading.swift
//
//  Created by Vadim Yelagin on 19/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation
import UIKit

public final class ImageLoading {

	public static let sharedInstance = ImageLoading()

	fileprivate let cache = Cache<String, DiscardableTask<UIImage, NSError>>()

	public func taskWithURL(_ url: URL) -> DiscardableTask<UIImage, NSError> {
		return taskWithRequest(URLRequest(url: url))
	}

	public func taskWithRequest(_ request: URLRequest) -> DiscardableTask<UIImage, NSError> {
		let url = request.url!.absoluteString
		if let task = cache.storage[url] {
			return task
		} else {
			let task = DiscardableTask<UIImage, NSError>()
			task.retry = { [weak self, weak task] in
				if let this = self, let task = task , task.isUndefinedOrFailed {
					this.startTask(task, withRequest: request)
				}
			}
			self.cache.storage[url] = task
			return task
		}
	}

	public func cachedImageWithURLString(_ urlString: String?) -> UIImage? {
		if let urlString = urlString, let task = cache.storage[urlString] {
			switch task.state {
			case .success(let result):
				return result
			default:
				break
			}
		}
		return nil
	}

	fileprivate func startTask(_ task: DiscardableTask<UIImage, NSError>, withRequest request: URLRequest) {
		task.state = .loading
		let session = URLSession.shared
		let op = session.dataTask(with: request, completionHandler: {
			[weak task] data, response, error in
			var state = DiscardableTaskState<UIImage, NSError>.undefined
			if let error = error as? NSError {
				if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
					return
				}
				state = .failure(error: error)
			} else if let data = data, let image = UIImage(data: data) {
				state = .success(result: image)
			}
			DispatchQueue.main.async {
				task?.state = state
				task?.cancel = nil
			}
		}) 
		task.cancel = { [weak op, weak task] in
			task?.state = .undefined
			op?.cancel()
		}
		op.resume()
	}
	
}
