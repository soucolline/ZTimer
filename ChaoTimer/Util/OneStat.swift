//
//  OneStat.swift
//  ChaoTimer
//
//  Created by Thomas Guilleminot on 19/07/2021.
//  Copyright © 2021 Jichao Li. All rights reserved.
//

import Foundation

@objcMembers class OneStat: NSObject {
    var statType: String
    var statValue: String

    init(statType: String, statValue: String) {
        self.statType = statType
        self.statValue = statValue
    }

    static func initWithType(statType: String, statValue: String) -> OneStat {
        OneStat(statType: statType, statValue: statValue)
    }
}
