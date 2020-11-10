//
//  LightningRepository.swift
//  wallet
//
//  Created by Jason on 8/30/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import Foundation

class LightningRepository {
    
    func createWallet(password: String, onSuccess: @escaping ([String]) -> Void, onFailure: @escaping (Error?) -> Void) {
        Lightning.shared.generateSeed { [weak self] (seed, error) in
            guard let self = self else { return }
            
            guard error == nil else {
                onFailure(error)
                return
            }
            
            Lightning.shared.createWallet(password: password, cipherSeedMnemonic: seed) { [weak self] (error) in
                guard self != nil else { return }
                
                guard error == nil else {
                    onFailure(error)
                    return
                }
                
                onSuccess(seed)
            }
        }
    }
    
    func openChannel(host: String, port: UInt, nodePubKey: NodePublicKey, closeAddress: String, onSuccess: @escaping (String) -> Void, onFailure: @escaping (Error?) -> Void) {
        
        Lightning.shared.connectToNode(nodePubkey: nodePubKey, hostAddress: host, hostPort: port) { [weak self] (response, error) in
            if error != nil && error?.localizedDescription.contains("already connected to peer") == false {
                onFailure(error)
                return
            }
            
            onSuccess("Connected to peer")
            
            Lightning.shared.openChannel(localFundingAmount: 20000, closeAddress: closeAddress, nodePubkey: nodePubKey) { (response, error) in
                guard error == nil else {
                    onFailure(error)
                    return
                }
                
                guard let update = response.update else {
                  return
                }
                
                switch update {
                case .chanPending(let pendingUpdate):
                    onSuccess("Channel open pending update\nTXID: \(pendingUpdate.txid.base64EncodedString())")
                case .chanOpen(let openUpdate):
                    onSuccess("Channel open success update")
                case .psbtFund(let onpsbtFund):
                    onSuccess("I don't know why you would get this error")
                }
            }
        }
    }
    
    func listChannels(onSuccess: @escaping (Lnrpc_ListChannelsResponse) -> Void, onFailure: @escaping (Error?) -> Void) {
        
        Lightning.shared.listChannels { (response, error) in
            guard error == nil else {
                onFailure(error)
                return
            }

            onSuccess(response)
        }
    }
    
    func wipeWallet(onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        Lightning.shared.stop { (error) in
            
            guard error == nil else {
                onFailure(error)
                return
            }
            
            Lightning.shared.purge()
            onSuccess()
            
        }
    }
    
    func getWalletBalance(onSuccess: @escaping (_ total: Int64, _ confirmed: Int64, _ unconfirmed: Int64) -> Void, onFailure: @escaping (Error?) -> Void) {
        Lightning.shared.walletBalance { [weak self] (balanceResponse, error) in
            guard self != nil else { return }

            guard error == nil else {
                onFailure(error)
                return
            }
            
            onSuccess(
                balanceResponse.totalBalance,
                balanceResponse.confirmedBalance,
                balanceResponse.unconfirmedBalance
            )
        }
    }
    
    func getNewAddress(onSuccess: @escaping (String) -> Void, onFailure: @escaping (Error?) -> Void) {
        Lightning.shared.newAddress { [weak self] (address, error) in
            guard self != nil else { return }
            
            guard error == nil else {
                onFailure(error)
                return
            }
            
            onSuccess(address)
        }
    }
    
    func getInfo(onSuccess: @escaping (Lnrpc_GetInfoResponse) -> Void, onFailure: @escaping (Error?) -> Void) {
        Lightning.shared.info { [weak self] (info, error) in
            guard self != nil else { return }
            
            guard error == nil else {
                onFailure(error)
                return
            }
            
            onSuccess(info)
        }
    }
    
    func unlockWallet(password: String, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        Lightning.shared.unlockWalet(password: password) { [weak self] (error) in
            guard self != nil else { return }
            
            guard error == nil else {
                onFailure(error)
                return
            }
            
            onSuccess()
        }
    }
    
    func pay(paymentRequest: String, onSuccess: @escaping (Lnrpc_PayReq) -> Void, onFailure: @escaping (Error?) -> Void) {
        Lightning.shared.decodePaymentRequest(paymentRequest) { [weak self] (decodedResponse, error) in
            guard self != nil else { return }

            guard error == nil else {
                onFailure(error)
                return
            }
            
            //Requst decoded succesfully so can be used to make the payment
            Lightning.shared.payRequest(paymentRequest) { [weak self] (sendResponse, error) in
                guard self != nil else { return }

                guard error == nil else {
                    onFailure(error)
                    return
                }
                
                onSuccess(decodedResponse)

            }
        }
    }
    
}
