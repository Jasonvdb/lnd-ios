//
//  Lightning.swift
//
//
//  Created by Jason van den Berg on 2020/08/02.
//

import Foundation

class Lightning {
    static let shared = Lightning()
    
    private var storage: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directory = documentsDirectory.appendingPathComponent("lnd")
        
        if !FileManager.default.fileExists(atPath: directory.path) {
            try! FileManager.default.createDirectory(atPath: directory.path, withIntermediateDirectories: true)
        }
        
        return directory
    }
    
    private let confName = "lnd.conf"
    
    private var confFile: URL {
        return storage.appendingPathComponent(confName)
    }
    
    //Ensure it stays a singleton
    private init() {}
    
    func start(_ completion: @escaping (Error?) -> Void, onRpcReady: @escaping (Error?) -> Void) {
        print("LND Start Request")
        
        //Delete previous config if it exists
        try? FileManager.default.removeItem(at: confFile)
        //Copy new config into LND directory
        do {
            //TODO build this config file in code
            let originalConf = "lnd.conf"
            try FileManager.default.copyItem(at: Bundle.main.bundleURL.appendingPathComponent(originalConf), to: confFile)
        } catch {
            return completion(error)
        }
        
        let args = "--lnddir=\(storage.path)"

        print(args)
        
        LndmobileStart(
            args,
            LndEmptyResponseCallback { (error) in
                completion(error)
                
                if error == nil {
                    EventBus.postToMainThread(.lndStarted)
                }
            },
            LndEmptyResponseCallback { (error) in
                onRpcReady(error)
                
                if error == nil {
                    EventBus.postToMainThread(.lndRpcReady)
                }
            }
        )
    }
    
    func stop(_ completion: @escaping (Error?) -> Void) {
        print("LND Stop Request")

        do {
            LndmobileStopDaemon(
                try Lnrpc_StopRequest().serializedData(),
                LndCallback<Lnrpc_StopResponse>({ (response, error) in
                    completion(error)
                    
                    if error == nil {
                        EventBus.postToMainThread(.lndStopped)
                    }
                })
            )
            completion(nil) //TODO figure out why callback is never hit by LndGenericCallback
        } catch {
            completion(error)
        }
    }
    
    func generateSeed(_ completion: @escaping ([String], Error?) -> Void) {
        do {
            LndmobileGenSeed(
                try Lnrpc_GenSeedRequest().serializedData(),
                LndCallback<Lnrpc_GenSeedResponse> { (response, error) in
                    completion(response.cipherSeedMnemonic, error)
                }
            )
        } catch {
            completion([], error)
        }
    }
   
    func createWallet(password: String, cipherSeedMnemonic: [String], completion: @escaping (Error?) -> Void) {
        guard let passwordData = password.data(using: .utf8) else {
            return completion(LightningError.invalidPassword)
        }
        
        var request = Lnrpc_InitWalletRequest()
        request.cipherSeedMnemonic = cipherSeedMnemonic
        request.walletPassword = passwordData
        
        do {
            LndmobileInitWallet(
                try request.serializedData(),
                LndEmptyResponseCallback { (error) in
                    completion(error)

                    if error == nil {
                        EventBus.postToMainThread(.lndWalletUnlocked)
                    }
                }
            )
        } catch {
            return completion(error)
        }
    }
    
    func unlockWalet(password: String, completion: @escaping (Error?) -> Void) {
        guard let passwordData = password.data(using: .utf8) else {
            return completion(LightningError.invalidPassword)
        }
        
        var request = Lnrpc_UnlockWalletRequest()
        request.walletPassword = passwordData
        
        do {
            LndmobileUnlockWallet(
                try request.serializedData(),
                LndEmptyResponseCallback { (error) in
                    completion(error)
                    
                    if error == nil {
                        EventBus.postToMainThread(.lndWalletUnlocked)
                    }
                }
            )
        } catch {
            return completion(error)
        }
    }

    func walletBalance(_ completion: @escaping (Lnrpc_WalletBalanceResponse, Error?) -> Void) {
        do {
            LndmobileWalletBalance(try Lnrpc_WalletBalanceRequest().serializedData(), LndCallback<Lnrpc_WalletBalanceResponse>(completion))
        } catch {
            completion(Lnrpc_WalletBalanceResponse(), error)
        }
    }
    
    func info(_ completion: @escaping (Lnrpc_GetInfoResponse, Error?) -> Void) {
        do {
            LndmobileGetInfo(try Lnrpc_GetInfoRequest().serializedData(), LndCallback<Lnrpc_GetInfoResponse>(completion))
        } catch {
            completion(Lnrpc_GetInfoResponse(), error)
        }
    }
    
    func newAddress(_ completion: @escaping (String, Error?) -> Void) {
        do {
            LndmobileNewAddress(
                try Lnrpc_NewAddressRequest().serializedData(),
                LndCallback<Lnrpc_NewAddressResponse> { (response, error) in
                    completion(response.address, error)
                }
            )
        } catch {
            completion("", error)
        }
    }
    
    func connectToNode(nodePubkey: NodePublicKey, hostAddress: String, hostPort: UInt, _ completion: @escaping (Lnrpc_ConnectPeerResponse, Error?) -> Void) {
        var request = Lnrpc_ConnectPeerRequest()
        var addr = Lnrpc_LightningAddress()
        addr.pubkey = nodePubkey.hexString
        addr.host = "\(hostAddress):\(hostPort)"
        request.addr = addr
        request.perm = true
        
        do {
            LndmobileConnectPeer(try request.serializedData(), LndCallback<Lnrpc_ConnectPeerResponse>(completion))
        } catch {
            completion(Lnrpc_ConnectPeerResponse(), error)
        }
    }
     
    func openChannel(localFundingAmount: Int64, closeAddress: String, nodePubkey: NodePublicKey, _ completion: @escaping (Lnrpc_OpenStatusUpdate, Error?) -> Void) {
        var request = Lnrpc_OpenChannelRequest()
        request.localFundingAmount = localFundingAmount
        request.closeAddress = closeAddress
        request.nodePubkey = nodePubkey.data
        request.pushSat = 0
        
        //TODO have the below config driven
        request.minConfs = 2
        request.targetConf = 2
        request.spendUnconfirmed = false
        
        do {
            LndmobileOpenChannel(try request.serializedData(), LndCallback<Lnrpc_OpenStatusUpdate>(completion))
        } catch {
            completion(Lnrpc_OpenStatusUpdate(), nil)
        }
    }
    
    func listChannels(_ completion: @escaping (Lnrpc_ListChannelsResponse, Error?) -> Void) {
        do {
            LndmobileListChannels(
                try Lnrpc_ListChannelsRequest().serializedData(),
                LndCallback<Lnrpc_ListChannelsResponse> { (response, error) in
                    completion(response, error)
                }
            )
        } catch {
            completion(Lnrpc_ListChannelsResponse(), error)
        }
    }
    
    func decodePaymentRequest(_ paymentRequest: String, _ completion: @escaping (Lnrpc_PayReq, Error?) -> Void) {
        var request = Lnrpc_PayReqString()
        request.payReq = paymentRequest
                
        do {
            LndmobileDecodePayReq(try request.serializedData(), LndCallback<Lnrpc_PayReq>(completion))
        } catch {
            completion(Lnrpc_PayReq(), nil)
        }
    }
    
    func payRequest(_ paymentRequest: String, _ completion: @escaping (Lnrpc_SendResponse, Error?) -> Void) {
        var request = Lnrpc_SendRequest()
        request.paymentRequest = paymentRequest
        
        do {
            //LND returns payment errors in the response and not with a real error. This just intercepts the callback and will return the custom error if applicable.
            LndmobileSendPaymentSync(
                try request.serializedData(),
                LndCallback<Lnrpc_SendResponse> { (response, error) in
                    guard response.paymentError.isEmpty else {
                        completion(response, LightningError.paymentError(response.paymentError))
                        return
                    }
                        
                    completion(response, error)
                })
            
        } catch {
            completion(Lnrpc_SendResponse(), nil)
        }
    }
}

//Utils
extension Lightning {
    func purge() {
        //TODO ensure testnet only
        print("WARNING: removing existing LND directory")
        try! FileManager.default.removeItem(at: storage)
    }
}

