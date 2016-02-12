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

	private let cache = Cache<String, DiscardableTask<UIImage, NSError>>()

	public func taskWithURL(url: NSURL) -> DiscardableTask<UIImage, NSError> {
		return taskWithRequest(NSURLRequest(URL: url))
	}

	public func taskWithRequest(request: NSURLRequest) -> DiscardableTask<UIImage, NSError> {
		let url = request.URL!.absoluteString
		if let task = cache.storage[url] {
			return task
		} else {
			let task = DiscardableTask<UIImage, NSError>()
			task.retry = { [weak self, weak task] in
				if let this = self, task = task where task.isUndefinedOrFailed {
					this.startTask(task, withRequest: request)
				}
			}
			self.cache.storage[url] = task
			return task
		}
	}

	public func cachedImageWithURLString(urlString: String?) -> UIImage? {
		if let urlString = urlString, task = cache.storage[urlString] {
			switch task.state {
			case .Success(let result):
				return result
			default:
				break
			}
		}
		return nil
	}

	private func startTask(task: DiscardableTask<UIImage, NSError>, withRequest request: NSURLRequest) {
		task.state = .Loading
		let session = NSURLSession.sharedSession()
		let op = session.dataTaskWithRequest(request) {
			[weak task] data, response, error in
			var state = DiscardableTaskState<UIImage, NSError>.Undefined
			if let error = error {
				if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
					return
				}
				state = .Failure(error: error)
			} else if let data = data, _ = response, image = UIImage(data: data) {
				state = .Success(result: image)
			}
			dispatch_async(dispatch_get_main_queue()) {
				task?.state = state
				task?.cancel = nil
			}
		}
		task.cancel = { [weak op, weak task] in
			task?.state = .Undefined
			op?.cancel()
		}
		op.resume()
	}
	
}
