//
//  UIImageView.swift
//  wallet
//
//  Created by Jason on 8/27/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit

extension UIImage {
    
    func tint(_ color: UIColor) -> UIImage {
        return withRenderingMode(.alwaysTemplate).withTintColor(color)
    }
    
}
