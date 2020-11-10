//
//  UIView.swift
//  wallet
//
//  Created by Jason on 8/23/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit

extension UIView {
    
    func addSubviewAndFill(_ view: UIView, top: CGFloat = 0.0, bottom: CGFloat = 0.0, leading: CGFloat = 0.0, trailing: CGFloat = 0.0) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: topAnchor, constant: top).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leading).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom).isActive = true
    }
    
}
