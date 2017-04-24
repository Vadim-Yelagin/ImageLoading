//
//  ImageLoadingView.swift
//
//  Created by Vadim Yelagin on 20/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import UIKit

open class ImageLoadingView: UIImageView {
	public typealias Task = DiscardableTask<UIImage>

	@IBInspectable public final var imageForUndefinedState: UIImage?
	@IBInspectable public final var imageForLoadingState: UIImage?
	@IBInspectable public final var imageForFailureState: UIImage?

	private var imageTaskUnobserve: (() -> ())?
	private var previousTask: Task? = nil
	private var previousState = Task.State.undefined
	public final var imageTask: Task? {
		didSet {
			if self.imageTask === oldValue {
				return
			}
			self.imageTaskUnobserve?()
			if let imageTask = self.imageTask {
				self.imageTaskUnobserve = imageTask.observe {
					[weak self] state in
					self?.transitionToState(state)
				}
			} else {
				self.imageTaskUnobserve = nil
				self.transitionToState(.undefined)
			}
		}
	}

	private func transitionToState(_ state: Task.State) {
		self.transition(
			from: self.previousState,
			ofTask: self.previousTask,
			to: state,
			ofTask: self.imageTask
		)
		self.previousState = state
		self.previousTask = self.imageTask
	}

	deinit {
		self.imageTaskUnobserve?()
	}

	public func setCommonPlaceholderImage(_ image: UIImage?) {
		self.imageForUndefinedState = image
		self.imageForLoadingState = image
		self.imageForFailureState = image
	}

	public func setImageTaskWithImage(_ image: UIImage?) {
		let task = Task()
		if let image = image {
			task.state = .success(result: image)
		} else {
			task.state = .undefined
		}
		self.imageTask = task
	}

	public func setImageTaskWithURLString(_ urlString: String?) {
		if let urlString = urlString, let url = URL(string: urlString) {
			self.imageTask = ImageLoading.shared.taskWithURL(url)
		} else {
			self.imageTask = nil
		}
	}

	public func setImageTaskWithURL(_ url: URL?) {
		if let url = url {
			self.imageTask = ImageLoading.shared.taskWithURL(url)
		} else {
			self.imageTask = nil
		}
	}

	public func setImageTaskWithRequest(_ request: URLRequest?) {
		if let request = request {
			self.imageTask = ImageLoading.shared.taskWithRequest(request)
		} else {
			self.imageTask = nil
		}
	}

	open func transition(
		from oldState: Task.State,
		ofTask oldTask: Task?,
		to newState: Task.State,
		ofTask newTask: Task?)
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

	@IBAction public func retryImageTask() {
		self.imageTask?.retry?()
	}

	@IBAction public func cancelImageTask() {
		self.imageTask?.cancel?()
	}
}
