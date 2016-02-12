//
//  FadeInImageLoadingView.swift
//
//  Created by Vadim Yelagin on 20/06/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

import Foundation
import UIKit

public class FadeInImageLoadingView: ImageLoadingView {

	public override func transitionFromState(
		oldState: DiscardableTaskState<UIImage, NSError>,
		ofTask oldTask: DiscardableTask<UIImage, NSError>?,
		toState newState: DiscardableTaskState<UIImage, NSError>,
		ofTask newTask: DiscardableTask<UIImage, NSError>?)
	{
		var fade = false
		if let oldTask = oldTask, newTask = newTask where oldTask === newTask {
			switch (oldState, newState) {
			case (.Loading, .Success):
				fade = true
			default:
				break
			}
		}
		func callSuper() {
			super.transitionFromState(oldState, ofTask: oldTask, toState: newState, ofTask: newTask)
		}
		if fade {
			UIView.transitionWithView(
				self,
				duration: 0.25,
				options: UIViewAnimationOptions.TransitionCrossDissolve,
				animations: callSuper,
				completion: nil)
		} else {
			callSuper()
		}
	}

}
