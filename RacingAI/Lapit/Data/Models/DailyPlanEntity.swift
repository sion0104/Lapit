import Foundation
import SwiftData

@Model
final class DailyPlanEntity {

    @Attribute(.unique) var checkDate: String

    var dateTitle: String
    var summaryTitle: String
    var summaryDescription: String

    var avgHRText: String
    var maxSpeedText: String
    var tesGoalText: String
    var warmupText: String
    
    var isCommitted: Bool

    @Attribute(.externalStorage) var mainItemsData: Data

    @Attribute(.externalStorage) var checklistData: Data

    var memo: String

    var updatedAt: Date

    init(
        checkDate: String,
        parsed: WorkoutPlan,
        checklist: [PlanCheckItem],
        memo: String,
        isCommitted: Bool = false
    ) {
        self.checkDate = checkDate

        self.dateTitle = parsed.dateTitle
        self.summaryTitle = parsed.summaryTitle
        self.summaryDescription = parsed.summaryDescription

        self.avgHRText = parsed.avgHRText
        self.maxSpeedText = parsed.maxSpeedText
        self.tesGoalText = parsed.tesGoalText
        self.warmupText = parsed.warmupText

        self.mainItemsData = (try? JSONEncoder().encode(parsed.mainItems)) ?? Data()
        self.checklistData = (try? JSONEncoder().encode(checklist)) ?? Data()

        self.memo = memo
        self.updatedAt = Date()
        self.isCommitted = isCommitted
    }

    var mainItems: [String] {
        get { (try? JSONDecoder().decode([String].self, from: mainItemsData)) ?? [] }
        set { mainItemsData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    var checklist: [PlanCheckItem] {
        get { (try? JSONDecoder().decode([PlanCheckItem].self, from: checklistData)) ?? [] }
        set { checklistData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }
}
