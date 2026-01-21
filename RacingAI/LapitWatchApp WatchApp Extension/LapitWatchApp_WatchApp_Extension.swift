//
//  LapitWatchApp_WatchApp_Extension.swift
//  LapitWatchApp WatchApp Extension
//
//  Created by 최시온 on 1/22/26.
//

import AppIntents

struct LapitWatchApp_WatchApp_Extension: AppIntent {
    static var title: LocalizedStringResource { "LapitWatchApp WatchApp Extension" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
