//
//  UserDefault+UpdateView.swift
//  GXVersionUpdateView
//
//  Created by 高广校 on 2024/4/18.
//

import Foundation
import GGXSwiftExtension

public extension Keys {
    static let versionUpdate = "versionUpdate"
}

public extension UserDefaults {

    /// 版本更新
    @UserDefaultWrapper(key: Keys.versionUpdate, defaultValue: "1.0.0")
    static var versionUpdate: String
    
}
