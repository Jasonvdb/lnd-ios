//
//  walletTests.swift
//  walletTests
//
//  Created by Jason on 8/12/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import XCTest
@testable import wallet

class walletTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPublicKey() {
        XCTAssertNoThrow(_ = try NodePublicKey("03236a685d30096b26692dce0cf0fa7c8528bdf61dbf5363a3ef6d5c92733a3016"))
        XCTAssertNoThrow(_ = try NodePublicKey("02346504c3bf5891949a3ff350585042557486c1fdb227639d7bb999e940c62c3a"))

        XCTAssertThrowsError(_ = try NodePublicKey("13236a685d30096b26692dce0cf0fa7c8528bdf61dbf5363a3ef6d5c92733a3016"))
        XCTAssertThrowsError(_ = try NodePublicKey("03236a685d30096b26692dce0cf0fa7c8528bdf61dbf5363a3ef6d5c92733a301"))
        XCTAssertThrowsError(_ = try NodePublicKey("lol"))
    }

    func testLND() {
        return //TODO figure out why LND can't be started from tests
        Lightning.shared.purge()
        
        let startExpectation = expectation(description: "LND started")
        let rpcExpectation = expectation(description: "LND RPC became ready")
        
        Lightning.shared.start({ (error) in
            XCTAssertNil(error, "Start LND error")
            startExpectation.fulfill()
        }) { (error) in
            XCTAssertNil(error, "Start RPC error")
            rpcExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
