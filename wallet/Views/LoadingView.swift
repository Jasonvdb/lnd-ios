//
//  LoadingView.swift
//  wallet
//
//  Created by Jason on 8/23/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    init() {
        super.init(frame: .zero)
        backgroundColor = Theme.backgroundColor
        addLoadingIndicator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addLoadingIndicator() {
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        self.addSubviewAndFill(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    
}
