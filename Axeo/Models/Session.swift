import Foundation
import SwiftData

@Model
final class Session {
    var id: UUID
    var userId: UUID
    var startedAt: Date
    var endedAt: Date
    var sessionType: SessionType
    var totalDurationSec: Int
    var completed: Bool
    var exerciseCount: Int
    var exerciseIndices: [Int]
    var accuracy: Int?

    init(
        id: UUID = UUID(),
        userId: UUID,
        startedAt: Date = .now,
        endedAt: Date = .now,
        sessionType: SessionType = .quick,
        totalDurationSec: Int = 0,
        completed: Bool = true,
        exerciseCount: Int = 0,
        exerciseIndices: [Int] = [],
        accuracy: Int? = nil
    ) {
        self.id = id
        self.userId = userId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.sessionType = sessionType
        self.totalDurationSec = totalDurationSec
        self.completed = completed
        self.exerciseCount = exerciseCount
        self.exerciseIndices = exerciseIndices
        self.accuracy = accuracy
    }

    enum SessionType: String, Codable {
        case quick
        case single
        case course
    }
}
