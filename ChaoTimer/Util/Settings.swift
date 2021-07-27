//
//  Settings.swift
//  ChaoTimer
//
//  Created by Thomas Guilleminot on 18/07/2021.
//  Copyright © 2021 Jichao Li. All rights reserved.
//

import Foundation

@objcMembers class Settings: NSObject {

    private let userDefaults = UserDefaults.standard

    func getFreezeTime() -> Int {
        var freezeTime: Int

        if self.hasObject(forKey: Const.keyFreezeTime) {
            freezeTime = userDefaults.integer(forKey: Const.keyFreezeTime)
        } else {
            freezeTime = Const.defaultFreezeTime
            userDefaults.set(freezeTime, forKey: Const.keyFreezeTime)
        }

        return freezeTime
    }

    func bool(forKey key: String) -> Bool {
        userDefaults.bool(forKey: key)
    }

    func int(forKey key: String) -> Int {
        userDefaults.integer(forKey: key)
    }

    func string(forKey key: String) -> String {
        userDefaults.string(forKey: key) ?? "7.0.0"
    }

    func object(forKey key: String) -> Any {
        userDefaults.object(forKey: key)!
    }

    func save(bool: Bool, forKey key: String) {
        userDefaults.set(bool, forKey: key)
    }

    func save(int: Int, forKey key: String) {
        userDefaults.set(int, forKey: key)
    }

    func save(string: String, forKey key: String) {
        userDefaults.set(string, forKey: key)
    }

    func save(object: Any, forKey key: String) {
        userDefaults.set(object, forKey: key)
    }

    func hasObject(forKey key: String) -> Bool {
        userDefaults.object(forKey: key) != nil
    }

    private struct Const {
        static let defaultFreezeTime = 50
        static let keyFreezeTime = "freezeTime"
        static let keyCurrentSession = "currentSession"
        static let defaultCurrentSession = "main session"
    }
}
