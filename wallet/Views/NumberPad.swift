//
//  NumberPad.swift
//  wallet
//
//  Created by Jason on 8/30/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit

class CheddarNumberPad: UIView {
    
    @objc private var onItemClicked: (String) -> Void
    @objc private var onBackspaceClicked: () -> Void

    init(onItemClicked: @escaping (String) -> Void, onBackspaceClicked: @escaping () -> Void) {
        self.onItemClicked = onItemClicked
        self.onBackspaceClicked = onBackspaceClicked
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = Theme.shadowColor
    }
    
    private func createButtons() {
        
        // Create 1 to 9
        for i in 1...10 {
            print(i)
        }
        
    }

}
