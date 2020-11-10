//
//  EventBus.swift
//  wallet
//
//  Created by Jason van den Berg on 2020/08/18.
//  Copyright © 2020 Jason. All rights reserved.
//

import Foundation

public enum EventTypes: String {
    case lndStateChange = "lnd-state-change"
    case lndStarted = "lnd-started"
    case lndStopped = "lnd-stopped"
    case lndRpcReady = "lnd-rpc-ready"
    case lndWalletUnlocked = "lnd-wallet-unlocked"
}

private let identifier = "app.lndtest.wallet.eventbus"

open class EventBus {
    static let shared = EventBus()
    static let queue = DispatchQueue(label: identifier, attributes: [])

    struct NamedObserver {
        let observer: NSObjectProtocol
        let eventType: EventTypes
    }

    var cache = [UInt: [NamedObserver]]()

    // MARK: Publish

    open class func postToMainThread(_ eventType: EventTypes, sender: Any? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: eventType.rawValue), object: sender)
        }
    }

    // MARK: Subscribe

    @discardableResult
    open class func on(_ target: AnyObject, eventType: EventTypes, sender: Any? = nil, queue: OperationQueue?, handler: @escaping ((Notification?) -> Void)) -> NSObjectProtocol {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: eventType.rawValue), object: sender, queue: queue, using: handler)
        let namedObserver = NamedObserver(observer: observer, eventType: eventType)

        EventBus.queue.sync {
            if let namedObservers = EventBus.shared.cache[id] {
                EventBus.shared.cache[id] = namedObservers + [namedObserver]
            } else {
                EventBus.shared.cache[id] = [namedObserver]
            }
        }

        return observer
    }

    @discardableResult
    open class func onMainThread(_ target: AnyObject, eventType: EventTypes, sender: Any? = nil, handler: @escaping ((Notification?) -> Void)) -> NSObjectProtocol {
        return EventBus.on(target, eventType: eventType, sender: sender, queue: OperationQueue.main, handler: handler)
    }

    @discardableResult
    open class func onBackgroundThread(_ target: AnyObject, eventType: EventTypes, sender: Any? = nil, handler: @escaping ((Notification?) -> Void)) -> NSObjectProtocol {
        return EventBus.on(target, eventType: eventType, sender: sender, queue: OperationQueue(), handler: handler)
    }

    // MARK: Unregister

    open class func unregister(_ target: AnyObject) {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let center = NotificationCenter.default

        EventBus.queue.sync {
            if let namedObservers = EventBus.shared.cache.removeValue(forKey: id) {
                for namedObserver in namedObservers {
                    center.removeObserver(namedObserver.observer)
                }
            }
        }
    }

    open class func unregister(_ target: AnyObject, eventType: EventTypes) {
        let id = UInt(bitPattern: ObjectIdentifier(target))
        let center = NotificationCenter.default

        EventBus.queue.sync {
            if let namedObservers = EventBus.shared.cache[id] {
                EventBus.shared.cache[id] = namedObservers.filter({ (namedObserver: NamedObserver) -> Bool in
                    if namedObserver.eventType == eventType {
                        center.removeObserver(namedObserver.observer)
                        return false
                    } else {
                        return true
                    }
                })
            }
        }
    }

}
