//
//  UIViewController+Extension.swift
//  FTDRefactor
//
//  Created by Jon E on 7/13/21.
//  Copyright © 2021 Jon E. All rights reserved.
//

import UIKit

var loadingView: UIView?

extension UIViewController {
    func showSpinner() {
        loadingView = UIView(frame: self.view.bounds)
        loadingView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
        let ai = UIActivityIndicatorView()
        ai.center = loadingView!.center
        ai.style = .large
        ai.startAnimating()
        loadingView?.addSubview(ai)
        self.view.addSubview(loadingView!)
    }
    
    func removeSpinner() {
        loadingView?.removeFromSuperview()
    }
}
