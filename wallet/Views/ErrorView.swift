//
//  ErrorView.swift
//  wallet
//
//  Created by Jason on 8/23/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit

class ErrorView: UIView {
    
    var title: String? {
        get {
            return label.text
        }
        set(newTitle) {
            label.text = newTitle
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = Theme.inverseBackgroundColor
        label.textAlignment = .center
        return UILabel()
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = Theme.backgroundColor
        addSubviewAndFill(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
