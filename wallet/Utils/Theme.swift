//
//  Theme.swift
//  wallet
//
//  Created by Jason on 8/20/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit

struct Theme {
    
    public static let primaryColor: UIColor = {
        return UIColor { (UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                return .systemTeal
            } else {
                return .systemTeal
            }
        }
    }()
    
    public static let primaryDarkColor: UIColor = {
        return UIColor { (UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                return .systemBlue
            } else {
                return .systemBlue
            }
        }
    }()
    
    public static let backgroundColor: UIColor = {
        return UIColor { (UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                return .gray900
            } else {
                return .white500
            }
        }
    }()
    
    public static let inverseBackgroundColor: UIColor = {
        return UIColor { (UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                return .white500
            } else {
                return .gray900
            }
        }
    }()
    
    public static let shadowColor: UIColor = {
        return UIColor { (UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                return UIColor.white500.withAlphaComponent(0.25)
            } else {
                return UIColor.gray900.withAlphaComponent(0.25)
            }
        }
    }()
    
}
