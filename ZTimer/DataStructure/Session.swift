//
//  Session.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 22/08/2021.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import Foundation

class Session: NSObject, NSCoding {
    private var timeArray: [Solve] = []
    var currentType: Int!
    var currentSubType: Int!
    var sessionName: String!

    override init() { }

    required init?(coder: NSCoder) {
        self.timeArray = coder.decodeObject(forKey: "timeArray") as! [Solve]
        self.currentType = coder.decodeObject(forKey: "currentType") as? Int
        self.currentSubType = coder.decodeObject(forKey: "currentSubType") as? Int
        self.sessionName = coder.decodeObject(forKey: "sessionName") as? String
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.timeArray, forKey: "timeArray")
        coder.encode(self.currentType, forKey: "currentType")
        coder.encode(self.currentSubType, forKey: "currentSubType")
        coder.encode(self.sessionName, forKey: "sessionName")
    }

    static func initWithDefault() -> Session {
        self.initWithName(name: "main session")
    }

    static func initWithName(name: String) -> Session {
        let session = Session()
        session.sessionName = name
        session.currentType = 1
        session.currentSubType = 0

        return session
    }

    func numberOfSolves() -> Int {
        self.timeArray.count
    }

    func addSolve(time: Int, withPenalty: PenaltyType, scramble: Scramble) {
        let newSolve = Solve.newSolveWithTime(newTime: time, penalty: withPenalty, scramble: scramble)
        newSolve.index = self.numberOfSolves()
        self.timeArray.append(newSolve)
    }

    func bestSolveOf(array: [Solve]) -> Solve {
        var min = array.last!

        for solve in self.timeArray {
            if solve.timeAfterPenalty() < min.timeAfterPenalty() {
                min = solve
            }
        }

        return min
    }

    func worstSolveOf(array: [Solve]) -> Solve {
        var max = array.last!

        for solve in self.timeArray {
            if solve.timeAfterPenalty() > max.timeAfterPenalty() {
                max = solve
            }
        }

        return max
    }

    func addPenaltyToLastSolve(penalty: PenaltyType) {
        if self.numberOfSolves() > 0 {
            self.timeArray.last?.penalty = penalty
        }
    }

    func deleteLastSolve() {
        if self.numberOfSolves() > 0 {
            self.timeArray.removeLast()
        }
    }

    func lastSolve() -> Solve {
        self.timeArray.last!
    }

    func bestSolve() -> Solve {
        self.bestSolveOf(array: self.timeArray)
    }

    func worstSolve() -> Solve {
        self.worstSolveOf(array: self.timeArray)
    }

    func bestAvgOf(num: Int) -> Solve {
        var bestavg = Int.max

        if self.numberOfSolves() >= num && self.numberOfSolves() >= 3 {
            var i = 0
            
            while i <= (self.numberOfSolves() - num) {
                var avg = 0
                var sum = 0
                var max = 0
                var DNFs = 0
                var min = Int.max

                for j in 0..<num {
                    let thisTime = self.timeArray[i+j].timeAfterPenalty()
                    let p = self.timeArray[i+j].penalty
                    if p == .dnf {
                        DNFs += 1
                    }

                    sum = sum + Int(thisTime)

                    if thisTime > max {
                        max = Int(thisTime)
                    }

                    if thisTime < min {
                        min = Int(thisTime)
                    }
                }

                if DNFs > 1 {
                    avg = Int.max
                } else {
                    sum = sum - min - max
                    avg = sum / (num - 2)
                }

                if bestavg > avg {
                    bestavg = avg
                }

                i += 1
            }
        }

        if bestavg == Int.max {
            bestavg = -1
        }

        var newPenalty = PenaltyType.noPenalty

        if bestavg == -1 {
            newPenalty = PenaltyType.dnf
        }

        return Solve.newSolveWithTime(newTime: bestavg, penalty: newPenalty, scramble: nil)
    }

    func currentAvgOf(num: Int) -> Solve {
        var avg = 0

        if self.numberOfSolves() >= num && self.numberOfSolves() >= 3 {
            var sum = 0
            var max = 0
            var min = Int.max
            var DNFs = 0

            var i = self.timeArray.count - num

            while i < self.timeArray.count {
                let thisTime = self.timeArray[i].timeAfterPenalty()
                let p = self.timeArray[i].penalty

                if p == .dnf {
                    DNFs += 1
                }

                sum = sum + thisTime

                if thisTime > max {
                    max = thisTime
                }

                if thisTime < min {
                    min = thisTime
                }

                i += 1
            }

            if DNFs > 1 {
                avg = -1
            } else {
                sum = sum - min - max
                avg = sum / (num - 2)
            }
        }

        var newPenalty = PenaltyType.noPenalty

        if avg == -1 {
            newPenalty = PenaltyType.dnf
        }

        return Solve.newSolveWithTime(newTime: avg, penalty: newPenalty, scramble: nil)
    }

    func sessionAvg() -> Solve {
        var avg = 0

        if self.numberOfSolves() >= 3 {
            var sum = 0
            var DNFs = 0

            for times in self.timeArray {
                let thisTime = times.timeAfterPenalty()
                let p = times.penalty

                sum = sum + thisTime
                if p == .dnf {
                    DNFs += 1
                }
            }

            if DNFs > 1 {
                avg = -1
            } else {
                sum = sum - self.bestSolve().timeAfterPenalty() - self.worstSolve().timeAfterPenalty()
                avg = sum / (self.numberOfSolves() - 2)
            }
        }

        var newPenalty = PenaltyType.noPenalty

        if avg == -1 {
            newPenalty = PenaltyType.dnf
        }

        return Solve.newSolveWithTime(newTime: avg, penalty: newPenalty, scramble: nil)
    }

    func sessionMean() -> Solve {
        var mean = 0

        if self.numberOfSolves() > 0 {
            var sum = 0
            var DNFs = 0

            for times in self.timeArray {
                let thisTime = times.timeAfterPenalty()
                let p = times.penalty

                if p == .dnf {
                    DNFs += 1
                } else {
                    sum = sum + thisTime
                }
            }

            if self.numberOfSolves() > DNFs {
                mean = sum / self.numberOfSolves() - DNFs
            } else {
                mean = -1
            }
        }

        var newPenalty = PenaltyType.noPenalty

        if mean == -1 {
            newPenalty = PenaltyType.dnf
        }

        return Solve.newSolveWithTime(newTime: mean, penalty: newPenalty, scramble: nil)
    }

    func getBest(solves: Int) -> [Solve] {
        var array: [Solve] = []
        var bestavg = Int.max
        var index = 0

        if self.numberOfSolves() >= solves && self.numberOfSolves() >= 3 {
            for i in 0...self.numberOfSolves() - solves {
                var avg = 0
                var sum = 0
                var max = 0
                var min = Int.max
                var DNFs = 0

                for j in 0..<solves {
                    let thisTime = self.timeArray[i+j].timeAfterPenalty()
                    let p = self.timeArray[i+j].penalty

                    if p == .dnf {
                        DNFs += 1
                    }

                    sum = sum + thisTime

                    if thisTime > max {
                        max = thisTime
                    }

                    if thisTime < min {
                        min = thisTime
                    }
                }

                if DNFs > 1 {
                    avg = Int.max
                } else {
                    sum = sum - min - max
                    avg = sum / (solves - 2)
                }

                if bestavg > avg {
                    bestavg = avg
                    index = i
                }
            }
        }

        for i in 0..<(index + solves) {
            array.append(self.timeArray[i])
        }

        return array
    }

    func getCurrent(solves: Int) -> [Solve] {
        var array: [Solve] = []

        if self.numberOfSolves() >= solves && self.numberOfSolves() >= 3 {
            var i = self.timeArray.count - solves

            while i < self.timeArray.count {
                array.append(self.timeArray[i])
                i += 1
            }
        }

        return array
    }

    func getAllSolves() -> [Solve] {
        self.timeArray
    }

    func numberOfSolvesToString() -> String {
        String(format: "%d", self.numberOfSolves())
    }

    func toString(containIndividualTime: Bool) -> String {
        var str = R.string.localizable.number_of_solves().appendingFormat("%d\n", self.numberOfSolves())

        if self.numberOfSolves() > 0 {
            let bestTime = R.string.localizable.best_time().appending(self.bestSolve().toString()).appending("\n")
            let worstTime = R.string.localizable.worst_time().appending(self.worstSolve().toString()).appending("\n")
            str = str.appending(bestTime).appending(worstTime)

            if !containIndividualTime {
                if self.numberOfSolves() >= 5 {
                    let ca5 = R.string.localizable.current_avg5().appending(self.currentAvgOf(num: 5).toString().appending("\n"))
                    let ba5 = R.string.localizable.best_avg5().appending(self.bestAvgOf(num: 5).toString().appending("\n"))
                    str = str.appending(ca5).appending(ba5)
                }

                if self.numberOfSolves() >= 12 {
                    let ca12 = R.string.localizable.current_avg12().appending(self.currentAvgOf(num: 12).toString().appending("\n"))
                    let ba12 = R.string.localizable.best_avg12().appending(self.bestAvgOf(num: 12).toString().appending("\n"))
                    str = str.appending(ca12).appending(ba12)
                }

                if self.numberOfSolves() >= 100 {
                    let ca100 = R.string.localizable.current_avg100().appending(self.currentAvgOf(num: 100).toString().appending("\n"))
                    let ba100 = R.string.localizable.best_avg100().appending(self.bestAvgOf(num: 100).toString().appending("\n"))
                    str = str.appending(ca100).appending(ba100)
                }
            }

            let sessionAvg = R.string.localizable.session_avg().appending(self.sessionAvg().toString().appending("\n"))
            let sessionMean = R.string.localizable.session_mean().appending(self.sessionMean().toString()).appending("\n")
            str = str.appending(sessionAvg).appending(sessionMean)

            if containIndividualTime {
                var notHasBest = true
                var notHasWorst = true
                var timesList: NSString = ""
                var tempBest = self.timeArray.last!
                var tempWorst = self.timeArray.last!

                for aTime in self.timeArray {
                    if aTime.timeAfterPenalty() > tempWorst.timeAfterPenalty() {
                        tempWorst = aTime
                    }

                    if aTime.timeAfterPenalty() < tempBest.timeAfterPenalty() {
                        tempBest = aTime
                    }
                }

                for aTime in self.timeArray {
                    var appendTime = aTime.toString()

                    if aTime == tempBest && notHasBest {
                        appendTime = String(format: "(%@)", appendTime)
                        notHasBest = false
                    } else if aTime == tempWorst && notHasWorst {
                        appendTime = String(format: "(%@)", appendTime)
                        notHasWorst = false
                    }

                    timesList = timesList.appending(appendTime).appending(", ") as NSString
                }

                timesList = timesList.substring(to: timesList.length - 2) as NSString
                let individualTimes = R.string.localizable.individual_times().appending("\n").appending(timesList as String)
                str = str.appending(individualTimes).appending("\n")
            }
        }

        if self.sessionName == "main session" {
            str = R.string.localizable.main_session().appending("\n\n").appending(str)
        } else {
            str = self.sessionName.appending("\n\n").appending(str)
        }

        return str
    }

    func removeSolve(at index: Int) {
        if self.numberOfSolves() > index {
            self.timeArray.remove(at: index)
        }
    }

    func removeSolve(aSolve: Solve) {
        self.timeArray.removeAll(where: { $0 == aSolve })
    }

    func clear() {
        self.timeArray.removeAll()
    }

    func setSolves(solves: [Solve]) {
        self.timeArray = solves
    }
}
