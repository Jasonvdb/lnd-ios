//
//  ExampleRepository.swift
//  wallet
//
//  Created by Jason on 8/23/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import Foundation

class ExampleRepository {
    
    // Perform fake request
    func getRandomInt(onSuccess: @escaping (Int) -> Void, onFailure: @escaping (Error) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            onSuccess(Int.random(in: 1..<100))
        }
    }
    
}
