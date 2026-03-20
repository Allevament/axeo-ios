import Foundation
import SwiftData

@Model
final class VisionTestResult {
    var id: UUID
    var userId: UUID
    var testType: String
    var timestamp: Date
    var summary: String
    var passed: Bool
    var details: [String: String]

    init(
        id: UUID = UUID(),
        userId: UUID,
        testType: String,
        timestamp: Date = .now,
        summary: String = "",
        passed: Bool = true,
        details: [String: String] = [:]
    ) {
        self.id = id
        self.userId = userId
        self.testType = testType
        self.timestamp = timestamp
        self.summary = summary
        self.passed = passed
        self.details = details
    }
}
