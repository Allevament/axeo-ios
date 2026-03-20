import Foundation
import SwiftData

@Model
final class CourseProgress {
    @Attribute(.unique) var courseId: String
    var userId: UUID
    var currentDay: Int
    var active: Bool
    var startedAt: Date
    var updatedAt: Date

    init(
        courseId: String,
        userId: UUID,
        currentDay: Int = 1,
        active: Bool = true,
        startedAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.courseId = courseId
        self.userId = userId
        self.currentDay = currentDay
        self.active = active
        self.startedAt = startedAt
        self.updatedAt = updatedAt
    }
}
