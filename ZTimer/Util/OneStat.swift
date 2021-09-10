//
//  OneStat.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 19/07/2021.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import Foundation

@objcMembers class OneStat: NSObject {
    enum StatType {
        case numberOfSolves
        case bestTime
        case worstTime
        case sessionAverage
        case sessionMean
        case currentAvg5
        case bestAvg5
        case currentAvg12
        case bestAvg12
        case currentAvg100
        case bestAvg100
    }

    var statType: StatType
    var statValue: String

    init(statType: StatType, statValue: String) {
        self.statType = statType
        self.statValue = statValue
    }

    func localizedStatType() -> String {
        switch statType {
            case .numberOfSolves: return R.string.localizable.number_of_solves()
            case .bestTime: return R.string.localizable.best_time()
            case .worstTime: return R.string.localizable.worst_time()
            case .sessionAverage: return R.string.localizable.session_average()
            case .sessionMean: return R.string.localizable.session_mean()
            case .currentAvg5: return R.string.localizable.current_avg5()
            case .bestAvg5: return R.string.localizable.best_avg5()
            case .currentAvg12: return R.string.localizable.current_avg12()
            case .bestAvg12: return R.string.localizable.best_avg12()
            case .currentAvg100: return R.string.localizable.current_avg100()
            case .bestAvg100: return R.string.localizable.best_avg100()
        }
    }
}
