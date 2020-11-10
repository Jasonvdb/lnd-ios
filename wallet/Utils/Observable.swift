//
//  Observable.swift
//  wallet
//
//  Created by Jason on 8/23/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import Foundation

class Observable<T> {
    
    private let thread: DispatchQueue
    var value: T? {
        willSet(newValue) {
              if let newValue = newValue {
                  thread.async {
                      self.observe?(newValue)
                  }
              }
        }
    }
    
    var observe: ((T) -> ())?
    init(_ value: T? = nil, thread dispatcherThread: DispatchQueue = DispatchQueue.main) {
        self.thread = dispatcherThread
        self.value = value
    }
    
}
