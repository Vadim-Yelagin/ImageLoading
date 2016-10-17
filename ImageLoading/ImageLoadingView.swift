//
//  ImageLoadingView.swift
//
//  Created by Vadim Yelagin on 20/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import UIKit

open class ImageLoadingView: UIImageView {

	@IBInspectable public final var imageForUndefinedState: UIImage?
	@IBInspectable public final var imageForLoadingState: UIImage?
	@IBInspectable public final var imageForFailureState: UIImage?

	fileprivate final var imageTaskUnobserve: ((Void) -> Void)?

	public final var imageTask: DiscardableTask<UIImage, NSError>? {
		didSet {
			let newValue = imageTask
			if oldValue === newValue {
				return
			}
			var prevTask = oldValue
			var prevState = oldValue?.state ?? .undefined
			imageTaskUnobserve?()
			imageTaskUnobserve = newValue?.observe {
				[weak self] state in
				if let this = self {
					this.transition(from: prevState, ofTask: prevTask, to: state, ofTask: newValue)
					prevState = state
					prevTask = newValue
				}
			}
			if newValue == nil {
				self.transition(from: prevState, ofTask: prevTask, to: .undefined, ofTask: newValue)
			}
		}
	}

	deinit {
		imageTaskUnobserve?()
	}

	open func setCommonPlaceholderImage(_ image: UIImage?) {
		self.imageForUndefinedState = image
		self.imageForLoadingState = image
		self.imageForFailureState = image
	}

	open func setImageTaskWithImage(_ image: UIImage?) {
		let task = DiscardableTask<UIImage, NSError>()
		if let image = image {
			task.state = .success(result: image)
		} else {
			task.state = .undefined
		}
		self.imageTask = task
	}

	open func setImageTaskWithURLString(_ urlString: String?) {
		if let urlString = urlString, let url = URL(string: urlString) {
			self.imageTask = ImageLoading.sharedInstance.taskWithURL(url)
		} else {
			self.imageTask = nil
		}
	}

	open func setImageTaskWithURL(_ url: URL?) {
		if let url = url {
			self.imageTask = ImageLoading.sharedInstance.taskWithURL(url)
		} else {
			self.imageTask = nil
		}
	}

	open func setImageTaskWithRequest(_ request: URLRequest?) {
		if let request = request {
			self.imageTask = ImageLoading.sharedInstance.taskWithRequest(request)
		} else {
			self.imageTask = nil
		}
	}

	open func transition(
		from oldState: DiscardableTaskState<UIImage, NSError>,
		ofTask oldTask: DiscardableTask<UIImage, NSError>?,
		to newState: DiscardableTaskState<UIImage, NSError>,
		ofTask newTask: DiscardableTask<UIImage, NSError>?)
	{
		switch newState {
		case .undefined:
			self.image = self.imageForUndefinedState
		case .loading:
			self.image = self.imageForLoadingState
		case .success(let result):
			self.image = result
		case .failure(_):
			self.image = self.imageForFailureState
		}
	}

	@IBAction open func retryImageTask() {
		self.imageTask?.retry?()
	}

	@IBAction open func cancelImageTask() {
		self.imageTask?.cancel?()
	}
	
}
