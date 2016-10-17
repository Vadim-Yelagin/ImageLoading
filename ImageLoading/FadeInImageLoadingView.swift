//
//  FadeInImageLoadingView.swift
//
//  Created by Vadim Yelagin on 20/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation
import UIKit

open class FadeInImageLoadingView: ImageLoadingView {

	open override func transition(
		from oldState: DiscardableTaskState<UIImage, NSError>,
		ofTask oldTask: DiscardableTask<UIImage, NSError>?,
		to newState: DiscardableTaskState<UIImage, NSError>,
		ofTask newTask: DiscardableTask<UIImage, NSError>?)
	{
		var fade = false
		if let oldTask = oldTask, let newTask = newTask , oldTask === newTask {
			switch (oldState, newState) {
			case (.loading, .success):
				fade = true
			default:
				break
			}
		}
		func callSuper() {
			super.transition(from: oldState, ofTask: oldTask, to: newState, ofTask: newTask)
		}
		if fade {
			UIView.transition(
				with: self,
				duration: 0.25,
				options: UIViewAnimationOptions.transitionCrossDissolve,
				animations: callSuper,
				completion: nil)
		} else {
			callSuper()
		}
	}

}
