//
//  LndCallbacks.swift
//  PayUp
//
//  Created by Jason van den Berg on 2020/08/03.
//  Copyright © 2020 Jason van den Berg. All rights reserved.
//

import Foundation
import SwiftProtobuf

extension Lightning {
    
    /// Generic callback for LND function which will map responses back into the protobuf message type.
    class LndCallback<T: SwiftProtobuf.Message>: NSObject, LndmobileCallbackProtocol, LndmobileRecvStreamProtocol {
        let completion: (T, Error?) -> Void

        init(_ completion: @escaping (T, Error?) -> Void) {
            let startedOnMainThread = Thread.current.isMainThread
            self.completion = { (response, error) in
                if startedOnMainThread {
                    DispatchQueue.main.async { completion(response, error) }
                } else {
                    completion(response, error)
                }
            }
        }
        
        func onResponse(_ p0: Data?) {
            guard let data = p0 else {
                completion(T(), nil) //For calls like balance checks, an empty response should just be `T` defaults
                return
            }
            
            do {
                completion(try T(serializedData: data), nil)
            } catch {
                completion(T(), LightningError.mapping)
            }
        }

        func onError(_ p0: Error?) {
            completion(T(), p0 ?? LightningError.unknown)
        }
    }
    
    /// For LND callbacks that don't pass back any messages but can return errors
    class LndEmptyResponseCallback: NSObject, LndmobileCallbackProtocol {
        let completion: (Error?) -> Void

        init(_ completion: @escaping (Error?) -> Void) {
            let startedOnMainThread = Thread.current.isMainThread
            self.completion = { error in
                
                if startedOnMainThread {
                    DispatchQueue.main.async { completion(error) }
                } else {
                    completion(error)
                }
            }
        }
        
        func onResponse(_ p0: Data?) {
            completion(nil)
        }

        func onError(_ p0: Error?) {
            completion(p0 ?? LightningError.unknown)
        }
    }
}
