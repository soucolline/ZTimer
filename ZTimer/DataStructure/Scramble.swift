//
//  Scramble.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 15/08/2021.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import Foundation

@objcMembers class Scramble: NSObject, NSCoding {
    var scrType = ""
    var scrSubType = ""
    var scramble = ""

    override init() {

    }

    required init?(coder: NSCoder) {
        self.scrType = coder.decodeObject(forKey: "scrambleType") as! String
        self.scrSubType = coder.decodeObject(forKey: "scrambleSubType") as! String
        self.scramble = coder.decodeObject(forKey: "scrambleString") as! String
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.scrType, forKey: "scrambleType")
        coder.encode(self.scrSubType, forKey: "scrambleSubType")
        coder.encode(self.scramble, forKey: "scrambleString")
    }

    static func getNewScramble(scrambler: CHTScrambler, type: Int, subType: Int) -> Scramble {
        let newScramble = Scramble()
        newScramble.setTypeAndSubTypeByType(type: type, subset: subType)
        newScramble.scramble = scrambler.getScrString(byType: Int32(type), subset: Int32(subType))

        return newScramble
    }

    func setTypeAndSubTypeByType(type: Int, subset: Int) {
        let plistUrl = Bundle.main.url(forResource: "scrambleTypes", withExtension: "plist")!
        let scrTypeDic = NSDictionary(contentsOf: plistUrl)
        let types = CHTScrambler.scrambleTypes() as! [String]
        let typeStr = types[type]
        let subsets = scrTypeDic?.object(forKey: typeStr) as! [String]
        let subsetStr = subsets[subset]

        self.scrType = typeStr
        self.scrSubType = subsetStr
    }
}
