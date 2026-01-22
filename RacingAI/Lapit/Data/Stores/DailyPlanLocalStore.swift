import Foundation
import SwiftData

@MainActor
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
        isCommitted: Bool,
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
            existing.isCommitted = isCommitted

            try context.save()
            return existing
        } else {
            let entity = DailyPlanEntity(
                checkDate: checkDate,
                parsed: parsed,
                checklist: checklist,
                memo: memo,
                isCommitted: isCommitted
            )
            context.insert(entity)
            try context.save()
            return entity
        }
    }
    
    static func delete(checkDate: String, context: ModelContext) throws {
        if let existing = try fetch(by: checkDate, context: context) {
            context.delete(existing)
            try context.save()
        }
    }
    
    static func replace(
        checkDate: String,
        parsed: WorkoutPlan,
        checklist: [PlanCheckItem],
        memo: String,
        isCommitted: Bool,
        context: ModelContext
    ) throws -> DailyPlanEntity {
        try delete(checkDate: checkDate, context: context)
        return try upsert(
            checkDate: checkDate,
            parsed: parsed,
            checklist: checklist,
            memo: memo,
            isCommitted: isCommitted,
            context: context
        )
    }
    
    @MainActor
    static func debugPrintAll(context: ModelContext) throws {
        let all = try context.fetch(FetchDescriptor<DailyPlanEntity>())
        print("📦 DailyPlanEntity count =", all.count)
        let dates = all.map { $0.checkDate }.sorted()
        print("📦 checkDates =", dates)
    }
}
