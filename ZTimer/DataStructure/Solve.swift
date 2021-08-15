//
//  Solve.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 15/08/2021.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import Foundation

@objcMembers class Solve: NSObject, NSCoding {
    var index: Int!
    var timeStamp: Date!
    var scramble: Scramble!
    var timeBeforePenalty: Int!
    var penalty: PenaltyType!

    override init() {
        
    }

    required init?(coder: NSCoder) {
        self.timeStamp = coder.decodeObject(forKey: "timeStamp") as? Date
        self.timeBeforePenalty = coder.decodeObject(forKey: "timeBeforePenalty") as? Int
        self.penalty = coder.decodeObject(forKey: "timePenalty") as? PenaltyType
        self.scramble = coder.decodeObject(forKey: "solveScramble") as? Scramble
    }

    func encode(with coder: NSCoder) {
        coder.encode(timeStamp, forKey: "timeStamp")
        coder.encode(timeBeforePenalty, forKey: "timeBeforePenalty")
        coder.encode(penalty, forKey: "timePenalty")
        coder.encode(scramble, forKey: "solveScramble")
    }

    func timeAfterPenalty() -> Int {
        var time = self.timeBeforePenalty

        if self.penalty == PENALTY_PLUS_2 {
            time = self.timeBeforePenalty + 2000
        } else if self.penalty == PENALTY_DNF {
            time = Int.max
        }

        return time!
    }

    func toString() -> String {
        var str = Utils.convertTimeFromMsecondToString(msecond: self.timeAfterPenalty())

        if penalty == PENALTY_PLUS_2 {
            str = str.appending("+")
        } else if penalty == PENALTY_DNF {
            str = "DNF"
        }

        return str
    }

    func getTimeStampString() -> String {
        DateFormatter.localizedString(from: self.timeStamp, dateStyle: .medium, timeStyle: .medium)
    }

    func setTime(newTimeBeforePenalty: Int, penalty: PenaltyType) {
        self.timeStamp = Date()
        self.timeBeforePenalty = newTimeBeforePenalty
        self.penalty = penalty
        self.scramble = Scramble()
    }

    static func newSolveWithTime(newTime: Int, penalty: PenaltyType, scramble: Scramble) -> Solve {
        let newSolve = Solve()
        newSolve.setTime(newTimeBeforePenalty: newTime, penalty: penalty)
        newSolve.scramble = scramble

        return newSolve
    }

}
