//
//  MPLogSwift.swift
//  MPLogSwift
//
//  Created by Michael Peternell on 06.04.2019.
//  Copyright © 2019 Michael Peternell. All rights reserved.
//

import Foundation

fileprivate class MPThreadIdAtom: NSObject {
    let number: Int
    private init(number: Int) {
        self.number = number
    }
    var letter: String {
        if number == 100 {
            return "+"
        }
        return String(UnicodeScalar(UInt8(97 + number)))
    }
    private static var UnavailableAtoms = Set<Int>()
    private static var CurrentNumber = 0
    private static let Lock = NSLock()
    private static var OverflowAtom = MPThreadIdAtom(number: 100)
    static func newId() -> MPThreadIdAtom {
        Lock.lock()
        defer { Lock.unlock() }
        
        for i in 0..<26 {
            let theNumber = (CurrentNumber + i) % 26
            if !UnavailableAtoms.contains(theNumber) {
                let atom = MPThreadIdAtom(number: theNumber)
                UnavailableAtoms.insert(theNumber)
                CurrentNumber = (theNumber + 1) % 26
                return atom
            }
        }
        
        return OverflowAtom
    }
    deinit {
        MPThreadIdAtom.Lock.lock()
        MPThreadIdAtom.UnavailableAtoms.remove(number)
        MPThreadIdAtom.Lock.unlock()
    }
}

public final class MPLogger {
    public struct Config {
        var verboseEnabled = false
        var debugEnabled = true
        var infoEnabled = true
        var warningEnabled = true
        var errorEnabled = true
    }
    
    public var config = Config()
    
    static func nullLogger() -> MPLogger {
        let logger = MPLogger()
        logger.config.verboseEnabled = false
        logger.config.debugEnabled = false
        logger.config.infoEnabled = false
        logger.config.warningEnabled = false
        logger.config.errorEnabled = false
        return logger
    }
    
    static func warningsAndErrorLogger() -> MPLogger {
        let logger = nullLogger()
        logger.config.warningEnabled = true
        logger.config.errorEnabled = true
        return logger
    }
    
    static func debugLogger() -> MPLogger {
        return MPLogger()
    }
    
    private static let dateFormatter: DateFormatter = {
        var df = DateFormatter()
        df.timeZone = TimeZone.current
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "HH:mm:ss.SSS"
        return df
    }()
    
    private static let threadIdKey = "MPLog_ThreadId"
    
    /// returns the current "thread ID".
    /// This is defined as:
    ///   'M' if the current thread is the main thread.
    ///   The letters 'a' to 'z' for background threads.
    ///   If we run out of lowercase letters, the letters are recycled. If there are
    ///   more than 26 background threads that do logging simultanuously, some
    ///   threads will get the special thread ID '+'.
    public static func getThreadId() -> String {
        let t = Thread.current
        if t.isMainThread {
            return "M"
        }
        if let atom = t.threadDictionary[threadIdKey] as? MPThreadIdAtom {
            return atom.letter
        }
        let atom = MPThreadIdAtom.newId()
        t.threadDictionary[threadIdKey] = atom
        return atom.letter
    }
    
    private func log(message: String, logType: String, filename: String, lineNumber: Int) {
        let now = Date()
        let dateString = MPLogger.dateFormatter.string(from: now)
        let threadId = MPLogger.getThreadId()
        let basename = (filename as NSString).lastPathComponent
        let fullString = "\(dateString) \(threadId) \(logType) \(basename)(\(lineNumber)): \(message)"
        print(fullString)
    }
    
    public func verbose(_ message: String, filename: String = #file, linenumber: Int = #line) {
        if config.verboseEnabled {
            log(message: message, logType: "TRACE", filename: filename, lineNumber: linenumber)
        }
    }
    
    public func debug(_ message: String, filename: String = #file, linenumber: Int = #line) {
        if config.debugEnabled {
            log(message: message, logType: "DEBUG", filename: filename, lineNumber: linenumber)
        }
    }
    
    public func debugFunctionStart(_ myself: Any? = nil, functionName: String = #function, filename: String = #file, linenumber: Int = #line) {
        if config.debugEnabled {
            let message: String
            if let myself = myself {
                message = "Start \(functionName) (\(myself))"
            } else {
                message = "Start \(functionName)"
            }
            log(message: message, logType: "DEBUG", filename: filename, lineNumber: linenumber)
        }
    }
    
    public func info(_ message: String, filename: String = #file, linenumber: Int = #line) {
        if config.infoEnabled {
            log(message: message, logType: "INFO ", filename: filename, lineNumber: linenumber)
        }
    }
    
    public func infoFunctionStart(_ myself: Any? = nil, functionName: String = #function, filename: String = #file, linenumber: Int = #line) {
        if config.infoEnabled {
            let message: String
            if let myself = myself {
                message = "Start \(functionName) (\(myself))"
            } else {
                message = "Start \(functionName)"
            }
            log(message: message, logType: "INFO ", filename: filename, lineNumber: linenumber)
        }
    }
    
    public func warning(_ message: String, filename: String = #file, linenumber: Int = #line) {
        if config.warningEnabled {
            log(message: message, logType: "WARN ", filename: filename, lineNumber: linenumber)
        }
    }
    
    public func error(_ message: String, filename: String = #file, linenumber: Int = #line) {
        if config.errorEnabled {
            log(message: message, logType: "ERROR", filename: filename, lineNumber: linenumber)
        }
    }
}
