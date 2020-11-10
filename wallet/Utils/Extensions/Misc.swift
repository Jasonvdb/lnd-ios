//
//  Misc.swift
//  wallet
//
//  Created by Jason on 8/30/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit

extension Array {
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    
}

extension String {
    
    func toQR(scale: CGFloat = 15.0) -> UIImage? {
        let data = self.data(using: String.Encoding.ascii)

        // Create the filter and transform it's scale
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
}
