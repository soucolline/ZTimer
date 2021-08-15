//
//  SessionManager.swift
//  ZTimer
//
//  Created by Thomas Guilleminot on 21/08/2021.
//  Copyright © 2021 Thomas Guilleminot. All rights reserved.
//

import Foundation

@objcMembers class SessionManager: NSObject, NSCoding {
    var sessionArray: [String] = []
    var stickySessionArray: [String] = ["main session"]
    var currentSessionName: String?

    override init() {}

    static func loadSessionWithName(name: String) -> CHTSession {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let fileName = path[0].appending("/\(Const.fileSessionPrefix)").appending(Utils().escapeString(string: name))
        var session: CHTSession
        let data = NSData(contentsOfFile: fileName)

        if let data = data {
            do {
                let unarchiver = try NSKeyedUnarchiver(forReadingWith: data as Data)
                session = unarchiver.decodeObject(forKey: Const.keySession) as! CHTSession
                unarchiver.finishDecoding()
            } catch {
                session = CHTSession.initWithDefault()
                print("init with default")
            }

            print("Load session : \(String(describing: session.sessionName))")
            return session
        } else {
            print("Session named \(name) not exit")
            session = CHTSession.initWithName(name)
            return session
        }
    }

    func loadCurrentSession() -> CHTSession {
        print("current session name = \(String(describing: self.currentSessionName))")
        return SessionManager.loadSessionWithName(name: self.currentSessionName ?? "main session")
    }

    func addSession(addName: String) {
        self.sessionArray.insert(addName, at: 0)
        self.currentSessionName = addName
    }

//    func removeSession(removeName: String) {
//        if self.stickySessionArray.contains(removeName) {
//            self.stickySessionArray.removeAll(where: { $0 == removeName })
//        } else {
//            self.sessionArray.removeAll(where: { $0 == removeName })
//        }
//
//        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let fileName = path[0].appending(Const.fileSessionPrefix).appending(removeName)
//        let fileManager = FileManager.default
//        try! fileManager.removeItem(atPath: fileName)
//    }

    func removeStickySession(at index: Int) {
        let removeName = self.stickySessionArray[index]
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let fileName = path[0].appending("/\(Const.fileSessionPrefix)").appending(removeName)
        let fileManager = FileManager.default
        try! fileManager.removeItem(atPath: fileName)
        self.stickySessionArray.remove(at: index)
    }

    func removeNormalSession(at index: Int) {
        let removeName = self.sessionArray[index]
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let fileName = path[0].appending("/\(Const.fileSessionPrefix)").appending(removeName)
        let fileManager = FileManager.default
        try! fileManager.removeItem(atPath: fileName)
        self.sessionArray.remove(at: index)
    }

    func stickySessionNum() -> Int {
        if stickySessionArray.count == 0 {
            stickySessionArray = ["main session"]
        }

        return self.stickySessionArray.count
    }

    func normalSessionNum() -> Int {
        self.sessionArray.count
    }

    func hasSession(sessionName: String) -> Bool {
        if self.sessionArray.contains(sessionName) {
            return true
        }

        if self.stickySessionArray.contains(sessionName) {
            return true
        }

        return false
    }

    func renameSession(from oldName: String, to newName: String) {
        if let row = self.stickySessionArray.firstIndex(where: { $0 == oldName }) {
            self.stickySessionArray[row] = newName
            let session = SessionManager.loadSessionWithName(name: oldName)
            session.sessionName = newName
            SessionManager.saveSession(session: session)
            if self.currentSessionName == oldName {
                self.currentSessionName = newName
            }
        } else if let row = self.sessionArray.firstIndex(where: { $0 == oldName }) {
            self.sessionArray[row] = newName
            let session = SessionManager.loadSessionWithName(name: oldName)
            session.sessionName = newName
            SessionManager.saveSession(session: session)
            if self.currentSessionName == oldName {
                self.currentSessionName = newName
            }
        } else {
            return
        }
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.sessionArray, forKey: Const.keySessionArray)
        coder.encode(self.stickySessionArray, forKey: Const.keyStickySessionArray)
        coder.encode(self.currentSessionName ?? "main session", forKey: Const.keyCurrentSessionName)
    }

    required init?(coder: NSCoder) {
        self.sessionArray = coder.decodeObject(forKey: Const.keySessionArray) as! [String]
        self.stickySessionArray = coder.decodeObject(forKey: Const.keyStickySessionArray) as! [String]
        self.currentSessionName = coder.decodeObject(forKey: Const.keyCurrentSessionName) as? String ?? "main session"
    }

    func save() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let fileName = path[0].appending("/\(Const.fileName)")
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(self, forKey: Const.keySessionManager)
        archiver.finishEncoding()

        if data.write(toFile: fileName, atomically: true) {
            print("save sessionManager")
        } else {
            print("App not saved")
        }
    }

    static func saveSession(session: CHTSession) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let fileName = path[0].appending("/\(Const.fileSessionPrefix)").appending(Utils().escapeString(string: session.sessionName))
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(session, forKey: Const.keySession)
        archiver.finishEncoding()

        if data.write(toFile: fileName, atomically: true) {
            print("save session : \(String(describing: session.sessionName))")
        }
    }

    static func loadd() -> SessionManager {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let fileName = path[0].appending("/\(Const.fileName)")
        var sessionManager: SessionManager
        let data = NSData(contentsOfFile: fileName)

        if let data = data, !data.isEmpty {
            let unarchiver = try! NSKeyedUnarchiver(forReadingWith: data as Data)
            sessionManager = unarchiver.decodeObject(forKey: Const.keySessionManager) as! SessionManager
            unarchiver.finishDecoding()
            print("get session manager, current \(String(describing: sessionManager.currentSessionName))")

            return sessionManager
        } else {
            sessionManager = SessionManager()
            let defaultSession = CHTSession.initWithDefault()
            SessionManager.saveSession(session: defaultSession!)
            sessionManager.save()

            return sessionManager
        }
    }

    private struct Const {
        static let keySessionManager = "sessionManager"
        static let keySessionArray = "sessionArray"
        static let keyStickySessionArray = "stickySessionArray"
        static let keyCurrentSessionName = "currentSessionName"
        static let keySession = "CHTSession"
        static let fileName = "CHTSessionManager"
        static let fileSessionPrefix = "CHTSession_"
    }
}
