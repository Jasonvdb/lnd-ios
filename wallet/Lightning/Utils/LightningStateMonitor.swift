//
//  LightningStateMonitor.swift
//  wallet
//
//  Created by Jason van den Berg on 2020/08/18.
//  Copyright © 2020 Jason. All rights reserved.
//

import Foundation

class LightningMonitorState {
    var lndRunning = false { didSet { onUpdate() } }
    var rpcReady = false { didSet { onUpdate() } }
    var walletUnlocked = false { didSet { onUpdate() } }
    var walletInfo = Lnrpc_GetInfoResponse() { didSet { onUpdate() } }
    
    var debuggingStatus: [String] {
        var entries: [String] = []
        entries.append("LND running: \(lndRunning ? "✅" : "❌")")
        entries.append("RPC ready: \(rpcReady ? "✅" : "❌")")
        entries.append("Wallet unlocked: \(walletUnlocked ? "✅" : "❌")")
        
        if walletUnlocked {
            entries.append("Synced to chain: \(walletInfo.syncedToChain ? "✅" : "❌")")
            entries.append("Block height: \(walletInfo.blockHeight)")
            entries.append("Peers: \(walletInfo.numPeers)")
        }
        
        return entries
    }

    //ALlow other components to subscribe to state changes from one place
    private func onUpdate() {
        EventBus.postToMainThread(.lndStateChange, sender: self)
    }
}

class LightningStateMonitor {
    public static let shared = LightningStateMonitor()

    var state = LightningMonitorState()

    private init() {
        EventBus.onMainThread(self, eventType: .lndStarted) { [weak self] (_) in
            self?.state.lndRunning = true
        }
        
        EventBus.onMainThread(self, eventType: .lndStopped) { [weak self] (_) in
            self?.state.lndRunning = false
            self?.state.walletUnlocked = false
            self?.state.rpcReady = false
        }
        
        EventBus.onMainThread(self, eventType: .lndRpcReady) { [weak self] (_) in
            self?.state.rpcReady = true
        }
        
        EventBus.onMainThread(self, eventType: .lndWalletUnlocked) { [weak self] (_) in
            self?.state.walletUnlocked = true
        }
        
        //TODO find better way to subscribe to LND events than this
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateInfo), userInfo: nil, repeats: true)
    }
    
    @objc private func updateInfo() {
        Lightning.shared.info { [weak self] (response, error) in
            guard let self = self else { return }
            guard error == nil else {
                return self.state.walletInfo = .init()
            }
            
            self.state.walletInfo = response
        }
    }
}
