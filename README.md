# Introduction

MPLogSwift is a very lightweight logging framework for Swift, written in pure Swift. It is inspired by [MPLog](https://github.com/michaelpeternell/MPLog/), which is kinda the same in Objective C.

It has less than 200 source lines of code, it is very performant, it has been
production-tested extensively, but it is still much more useful than `NSLog`
or `print`.

**The main advantage of MPLogSwift is its very nice debug log message format.** And of course the low price (it's free as in beer).

It has been tested with Swift 5. It definitively works with iOS 9, iOS 12, iOS 13.

This is not a logging “framework”, this is just a very short subprogram. But it does the job, and you may consider using it instead of `print` or `NSLog`.

I once joined a project that used another logging library. It had all kinds of special abilities, for example it uploaded the encrypted logs to some special cloud server. Then I asked the co-worker where I can access these files in the cloud, and he replied: “you don't have to go to the cloud to see the logs, they are in the Xcode console anyways.” That answer motivated me to throw that framework away and to use MPLog instead. No one noticed any difference, but the binary became smaller, and the logs were appearing in realtime on the console, and there were no more crashes in the logging function.

# Usage

Just put MPLogSwift.swift somewhere in your project and create a logger like this:

    let log = MPLogger.debugLogger()

Then you can call it whenever you need it:

    log.debug("Hello there")

and the line on the console will look like this:

    18:57:06.209 M DEBUG AppDelegate.swift(43): Hello there

The difference with NSLog is this:

- it contains no date, you know what day it is, you usually just need the minutes, seconds, and milliseconds. But hours are included too, of course.
- it contains the current thread from where the logging method was called. E.g. "M" for main thread, and "a" - "z" for the background threads. If we run out of letters, we use "+", but this rarely happens, because letters are recycled, and we rarely have more than 26 background threads that all do debug logging.
- it doesn't contain the name of the current process, because when you look at the debug console you know what program you are currently running.
- it also doesn't contain the process or thread ID, I think the one-character-thread identifier is much more useful.
- it contains the filename and line from where the log method has been called.
- it contains the debug level, like DEBUG, INFO, WARN, ERROR.

# License

A very liberal MIT license. If you have other licensing needs, you may [contact me](https://www.michaelpeternell.at/).
