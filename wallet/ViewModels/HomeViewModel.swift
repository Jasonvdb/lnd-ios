//
//  HomeViewModel.swift
//  wallet
//
//  Created by Jason on 8/23/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import Foundation

class HomeViewModel: ViewModel {
    
    private let exampleRepo = ExampleRepository()
    private let lightningRepo = LightningRepository()
    
    let isLoading = Observable<Bool>()
    let randomInt = Observable<Int>()
    let error = Observable<Error>()
    let resultMessage = Observable<String>()
    let walletWipe = Observable<Void>()
    let newAddress = Observable<String>()
    
    //TODO: Hardcoded values. Change these later.
    private let nodePubKey = try! NodePublicKey("02d1ae7c35e0cc8774f889cdaeccdd76920801fcc203956b8d5169d0c74014bcfc")
    private let hostAddress = "127.0.0.1"
    private let hostPort: UInt = 9739
    private let closeAddress = "tb1qylxttvn7wm7vsc2j36cjvmpl7nykcrzqkz6avl"
    private let invoice = "lnbcrt1u1p04e4cypp5qyxj3u8dm2pjsdang94lj6c0d9p33l05999945atjrfyw0nle0ssdqqcqzpgsp5dqlzsd63a0akx9wgv8v9scryj3gn7fe3s8ca9l26s9tjlwkvtv4q9qy9qsq4kv825h86yummfcerkvctfh8c4aw6vc0r986dsyjtp6dun5ysurq2zh0nj6qd4cuf5qskpn9pwre5u26ncce4qy3ataw88p6j08y0xcqy4uxa7"
    
    func load() {
        
        isLoading.value = true
        
        // This is an example of a fetch to some data provider (i.e. an http api or something else)
        // and where you can place the observed response
        exampleRepo.getRandomInt(
            onSuccess: { [weak self] someInt in
                self?.isLoading.value = false
                self?.randomInt.value = someInt
            },
            onFailure: { [weak self] error in
                self?.isLoading.value = false
                self?.error.value = error
            })
        
    }
    
    func createWallet(password: String) {
        
        self.resultMessage.value = ""
        self.isLoading.value = true
        
        lightningRepo.createWallet(
            password: password,
            onSuccess: { [weak self] seed in
                self?.isLoading.value = false
                self?.resultMessage.value = seed.joined(separator: ",")
            },
            onFailure: { [weak self] error in
                self?.isLoading.value = false
                self?.resultMessage.value = error?.localizedDescription // TODO: Change to error
            })
        
    }
    
    func unlockWallet(password: String) {
        
        self.resultMessage.value = ""
        self.isLoading.value = true
        
        lightningRepo.unlockWallet(
            password: password,
            onSuccess: { [weak self] in
                self?.isLoading.value = false
                self?.resultMessage.value = "Wallet unlocked"
            },
            onFailure: { [weak self] error in
                self?.isLoading.value = false
                self?.resultMessage.value = error?.localizedDescription // TODO: Change to error
            })
    }
    
    func openChannel() {
        
        self.resultMessage.value = ""
        self.isLoading.value = true
        
        lightningRepo.openChannel(
            host: hostAddress,
            port: hostPort,
            nodePubKey: nodePubKey,
            closeAddress: closeAddress,
            onSuccess: { [weak self] message in
                self?.isLoading.value = false
                self?.resultMessage.value = message
            },
            onFailure: { [weak self] error in
                self?.isLoading.value = false
                self?.resultMessage.value = error?.localizedDescription // TODO: Change to error
            })
    }
    
    func listChannels() {
        
        self.resultMessage.value = ""
        self.isLoading.value = true
        
        lightningRepo.listChannels(onSuccess: { [weak self] (response) in
            self?.isLoading.value = false
            self?.resultMessage.value = response.channels.map({ (channel) in
                return "\(channel.remotePubkey):\nCan send: \(channel.localBalance) - Can receive: \(channel.remoteBalance)"
            }).joined(separator: "\n\n")
        }) { [weak self] (error) in
            self?.isLoading.value = false
            self?.resultMessage.value = error?.localizedDescription
        }
    }
    
    func payInvoice() {
        
        self.resultMessage.value = ""
        self.isLoading.value = true
        
        lightningRepo.pay(paymentRequest: invoice, onSuccess: { [weak self] (response) in
            self?.isLoading.value = false
            self?.resultMessage.value = "Paid \(response.numSatoshis) sats to \(response.destination)"
        },
        onFailure: { [weak self] error in
            self?.isLoading.value = false
            self?.resultMessage.value = error?.localizedDescription // TODO: Change to error
        })
    }
    
    func wipeWallet() {
        
        self.resultMessage.value = ""
        self.isLoading.value = true
        
        lightningRepo.wipeWallet(
            onSuccess: { [weak self] in
                self?.isLoading.value = false
                self?.walletWipe.value = ()
            },
            onFailure: { [weak self] error in
                self?.isLoading.value = false
                self?.resultMessage.value = error?.localizedDescription // TODO: Change to error
            })
    }
    
    func getWalletBalance() {
        
        self.resultMessage.value = ""
        self.isLoading.value = true
        
        lightningRepo.getWalletBalance(
            onSuccess: { [weak self] (total, confirmed, unconfirmed) in
                self?.isLoading.value = false
                self?.resultMessage.value = "Total: \(total)\nConfirmed: \(confirmed)\nUnconfirmed: \(unconfirmed)"
            },
            onFailure: { [weak self] error in
                self?.isLoading.value = false
                self?.resultMessage.value = error?.localizedDescription // TODO: Change to error
            })
    }
    
    func getInfo() {
        
        self.resultMessage.value = ""
        self.isLoading.value = true
        
        lightningRepo.getInfo { [weak self] (res) in
            self?.isLoading.value = false
            self?.resultMessage.value = "Version \(res.version)\nChain: \(res.chains.first?.network ?? "")\nPeers: \(res.numPeers)\nPubkey: \(res.identityPubkey)\n"
        } onFailure: { [weak self] (error) in
            self?.isLoading.value = false
            self?.resultMessage.value = error?.localizedDescription // TODO: Change to error
        }
    }
    
    func getNewAddress() {
        
        self.resultMessage.value = ""
        self.isLoading.value = true
        
        lightningRepo.getNewAddress(
            onSuccess: { [weak self] address in
                self?.isLoading.value = false
                self?.newAddress.value = address
            },
            onFailure: { [weak self] error in
                self?.isLoading.value = false
                self?.resultMessage.value = error?.localizedDescription // TODO: Change to error
            })
    }
    
}
