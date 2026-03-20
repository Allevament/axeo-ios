import UserNotifications
import SwiftUI

/// Centralized notification scheduling for exercise reminders.
@Observable
final class NotificationManager {
    static let shared = NotificationManager()

    // MARK: – User preferences (persisted via UserDefaults)

    var remindersEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "axeo_reminders_enabled") }
        set {
            UserDefaults.standard.set(newValue, forKey: "axeo_reminders_enabled")
            if newValue { scheduleDaily() } else { cancelAll() }
        }
    }

    /// Hour component of the daily reminder (0–23). Default = 9 (9 AM).
    var reminderHour: Int {
        get {
            let val = UserDefaults.standard.integer(forKey: "axeo_reminder_hour")
            return val == 0 && !UserDefaults.standard.bool(forKey: "axeo_reminder_hour_set") ? 9 : val
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "axeo_reminder_hour")
            UserDefaults.standard.set(true, forKey: "axeo_reminder_hour_set")
            if remindersEnabled { scheduleDaily() }
        }
    }

    /// Minute component of the daily reminder (0–59). Default = 0.
    var reminderMinute: Int {
        get { UserDefaults.standard.integer(forKey: "axeo_reminder_minute") }
        set {
            UserDefaults.standard.set(newValue, forKey: "axeo_reminder_minute")
            if remindersEnabled { scheduleDaily() }
        }
    }

    // MARK: – Authorisation

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    // MARK: – Daily Reminder

    private static let dailyReminderID = "axeo-daily-reminder"

    func scheduleDaily() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.dailyReminderID])

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Time for Eye Training", comment: "")
        content.body = NSLocalizedString("Your eyes need a workout too! A quick 5-minute session keeps them sharp.", comment: "")
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = reminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: Self.dailyReminderID, content: content, trigger: trigger)

        center.add(request)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: – Streak Reminder (fires if user hasn't trained today by evening)

    private static let streakReminderID = "axeo-streak-reminder"

    func scheduleStreakReminder() {
        guard remindersEnabled else { return }
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.streakReminderID])

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Don't Break Your Streak!", comment: "")
        content.body = NSLocalizedString("You haven't trained today. A quick session keeps your streak alive.", comment: "")
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: Self.streakReminderID, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelStreakReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [Self.streakReminderID]
        )
    }

    // MARK: – Formatted time for display

    var formattedReminderTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        var comps = DateComponents()
        comps.hour = reminderHour
        comps.minute = reminderMinute
        let date = Calendar.current.date(from: comps) ?? .now
        return formatter.string(from: date)
    }
}
