import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var displayName: String
    var email: String
    var birthYear: Int?
    var diagnosis: Diagnosis?
    var goal: Goal
    var kidMode: Bool
    var profilePhotoData: Data?
    var preferredLanguage: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        displayName: String,
        email: String,
        birthYear: Int? = nil,
        diagnosis: Diagnosis? = nil,
        goal: Goal = .prevention,
        kidMode: Bool = false,
        profilePhotoData: Data? = nil,
        preferredLanguage: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.birthYear = birthYear
        self.diagnosis = diagnosis
        self.goal = goal
        self.kidMode = kidMode
        self.profilePhotoData = profilePhotoData
        self.preferredLanguage = preferredLanguage
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: – Enums

    enum Diagnosis: String, Codable, CaseIterable, Identifiable {
        case none
        case myopia
        case hyperopia
        case astigmatism
        case presbyopia
        case dryEye
        case other

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .none:         NSLocalizedString("No known condition", comment: "")
            case .myopia:       NSLocalizedString("Nearsightedness", comment: "")
            case .hyperopia:    NSLocalizedString("Farsightedness", comment: "")
            case .astigmatism:  NSLocalizedString("Astigmatism", comment: "")
            case .presbyopia:   NSLocalizedString("Presbyopia", comment: "")
            case .dryEye:       NSLocalizedString("Dry Eye", comment: "")
            case .other:        NSLocalizedString("Other", comment: "")
            }
        }
    }

    enum Goal: String, Codable, CaseIterable, Identifiable {
        case prevention
        case correction
        case relaxation

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .prevention:  NSLocalizedString("Prevention", comment: "")
            case .correction:  NSLocalizedString("Correction", comment: "")
            case .relaxation:  NSLocalizedString("Relaxation", comment: "")
            }
        }

        var icon: String {
            switch self {
            case .prevention:  "shield.checkered"
            case .correction:  "target"
            case .relaxation:  "leaf.fill"
            }
        }

        var description: String {
            switch self {
            case .prevention:  NSLocalizedString("Keep your vision sharp and prevent future problems", comment: "")
            case .correction:  NSLocalizedString("Strengthen eye muscles and improve focus", comment: "")
            case .relaxation:  NSLocalizedString("Reduce eye strain and digital fatigue", comment: "")
            }
        }
    }
}
