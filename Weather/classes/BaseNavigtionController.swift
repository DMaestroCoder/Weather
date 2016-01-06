//
//  NavigtionController.swift
//  Weather
//
//  Copyright © 2016 dmitry. All rights reserved.
//

import UIKit

class BaseNavigationController : UINavigationController {
	@IBOutlet var loadingView : UIView!
	@IBOutlet var loadingIndicator : UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		loadingView.layer.cornerRadius = 5.0
		loadingView.layer.masksToBounds = true
	}
	
	func startLoading() {
		loadingView.center = self.view.center
		loadingIndicator.startAnimating()
		self.view.addSubview(loadingView)
	}
	
	func stopLoading() {
		loadingIndicator.stopAnimating()
		loadingView.removeFromSuperview()
	}
}
