//
//  LapitWatchAppExtentsion.swift
//  LapitWatchAppExtentsion
//
//  Created by 최시온 on 12/28/25.
//

import AppIntents

struct LapitWatchAppExtentsion: AppIntent {
    static var title: LocalizedStringResource { "LapitWatchAppExtentsion" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
