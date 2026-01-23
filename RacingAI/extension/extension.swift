//
//  extension.swift
//  extension
//
//  Created by 최시온 on 1/23/26.
//

import AppIntents

struct LapitWatchextension: AppIntent {
    static var title: LocalizedStringResource { "extension" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
