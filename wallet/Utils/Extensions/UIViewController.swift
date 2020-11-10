//
//  UIViewController.swift
//  wallet
//
//  Created by Jason van den Berg on 2020/08/18.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setTheme() {
        view.backgroundColor = Theme.backgroundColor
        setNavBarStyles()
    }
    
    func setNavBarStyles() {

        // Color
        navigationController?.navigationBar.barTintColor = Theme.backgroundColor
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = Theme.inverseBackgroundColor
        
        // Shadow
        navigationController?.navigationBar.layer.shadowColor = Theme.shadowColor.cgColor
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: CGFloat(Dimens.shadow))
        navigationController?.navigationBar.layer.shadowRadius = 0.0
        navigationController?.navigationBar.layer.shadowOpacity = 1.0
        navigationController?.navigationBar.layer.masksToBounds = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // Text
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Theme.inverseBackgroundColor,
            NSAttributedString.Key.font: Fonts.sofiaPro(weight: .medium, Dimens.titleText)
        ]
        
    }
    
    func hideKeyboardWhenSwipedDown() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        view.addGestureRecognizer(swipeDown)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
