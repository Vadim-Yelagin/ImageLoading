//
//  ImageLoadingView.swift
//
//  Created by Vadim Yelagin on 20/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import UIKit

public class ImageLoadingView: UIImageView {
    
    @IBInspectable public final var imageForUndefinedState: UIImage?
    @IBInspectable public final var imageForLoadingState: UIImage?
    @IBInspectable public final var imageForFailureState: UIImage?
    
    private final var imageTaskUnobserve: (Void -> Void)?
    
    public final var imageTask: DiscardableTask<UIImage, NSError>? {
        didSet {
            let newValue = imageTask
            if oldValue === newValue {
                return
            }
            var prevTask = oldValue
            var prevState = oldValue?.state ?? .Undefined
            imageTaskUnobserve?()
            imageTaskUnobserve = newValue?.observe {
                [weak self] state in
                if let this = self {
                    this.transitionFromState(prevState, ofTask: prevTask, toState: state, ofTask: newValue)
                    prevState = state
                    prevTask = newValue
                }
            }
            if newValue == nil {
                self.transitionFromState(prevState, ofTask: prevTask, toState: .Undefined, ofTask: newValue)
            }
        }
    }
    
    deinit {
        imageTaskUnobserve?()
    }
  
    public func setCommonPlaceholderImage(image: UIImage?) {
        self.imageForUndefinedState = image
        self.imageForLoadingState = image
        self.imageForFailureState = image
    }
    
    public func setImageTaskWithImage(image: UIImage?) {
        let task = DiscardableTask<UIImage, NSError>()
        if let image = image {
            task.state = .Success(result: Box(image))
        } else {
            task.state = .Undefined
        }
        self.imageTask = task
    }
    
    public func setImageTaskWithURLString(urlString: String?) {
        if let urlString = urlString, url = NSURL(string: urlString) {
            self.imageTask = ImageLoading.sharedInstance.taskWithURL(url)
        } else {
            self.imageTask = nil
        }
    }
    
    public func setImageTaskWithURL(url: NSURL?) {
        if let url = url {
            self.imageTask = ImageLoading.sharedInstance.taskWithURL(url)
        } else {
            self.imageTask = nil
        }
    }
    
    public func setImageTaskWithRequest(request: NSURLRequest?) {
        if let request = request {
            self.imageTask = ImageLoading.sharedInstance.taskWithRequest(request)
        } else {
            self.imageTask = nil
        }
    }
    
    public func transitionFromState(
        oldState: DiscardableTaskState<UIImage, NSError>,
        ofTask oldTask: DiscardableTask<UIImage, NSError>?,
        toState newState: DiscardableTaskState<UIImage, NSError>,
        ofTask newTask: DiscardableTask<UIImage, NSError>?)
    {
        switch newState {
        case .Undefined:
            self.image = self.imageForUndefinedState
        case .Loading:
            self.image = self.imageForLoadingState
        case .Success(let result):
            self.image = result.value
        case .Failure(let error):
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
