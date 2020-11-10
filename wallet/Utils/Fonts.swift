//
//  Fonts.swift
//  wallet
//
//  Created by Jason on 8/20/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit

public enum FontStyle {
    case regular
    case medium
    case bold

    var name: String {
        switch self {
        case .regular:  return "SofiaProRegular"
        case .medium:   return "SofiaProMedium"
        case .bold:     return "SofiaProBold"
        }
    }
}

struct Fonts {
    
    public static func sofiaPro(weight: FontStyle = .regular, _ size: Int = 16) -> UIFont {
        return UIFont(name: weight.name, size: CGFloat(size))!
    }
    
}
