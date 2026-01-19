import Foundation
import SwiftData

enum DailyPlanLocalStore {

    static func fetch(by checkDate: String, context: ModelContext) throws -> DailyPlanEntity? {
        let descriptor = FetchDescriptor<DailyPlanEntity>(
            predicate: #Predicate { $0.checkDate == checkDate },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try context.fetch(descriptor).first
    }

    static func upsert(
        checkDate: String,
        parsed: WorkoutPlan,
        checklist: [PlanCheckItem],
        memo: String,
        context: ModelContext
    ) throws -> DailyPlanEntity {
        if let existing = try fetch(by: checkDate, context: context) {
            existing.dateTitle = parsed.dateTitle
            existing.summaryTitle = parsed.summaryTitle
            existing.summaryDescription = parsed.summaryDescription
            existing.avgHRText = parsed.avgHRText
            existing.maxSpeedText = parsed.maxSpeedText
            existing.tesGoalText = parsed.tesGoalText
            existing.warmupText = parsed.warmupText
            existing.mainItems = parsed.mainItems

            existing.checklist = checklist
            existing.memo = memo
            existing.updatedAt = Date()

            try context.save()
            return existing
        } else {
            let entity = DailyPlanEntity(
                checkDate: checkDate,
                parsed: parsed,
                checklist: checklist,
                memo: memo
            )
            context.insert(entity)
            try context.save()
            return entity
        }
    }
}
