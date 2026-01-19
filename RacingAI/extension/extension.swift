//
//  extension.swift
//  extension
//
//  Created by 최시온 on 1/19/26.
//

import AppIntents

struct LapitWatchAppExtension: AppIntent {
    static var title: LocalizedStringResource { "extension" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
