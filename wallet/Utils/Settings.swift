//
//  Settings.swift
//  wallet
//
//  Created by Jason van den Berg on 2020/08/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import Foundation

class Settings {
    static var isUnitTest = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}
