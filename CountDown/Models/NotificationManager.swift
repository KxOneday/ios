import Foundation
import UserNotifications

struct NotificationManager {
    static func scheduleNotification(for event: CountdownEvent) {
        guard event.reminderDaysBefore > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "倒数日提醒"
        content.body = "还有\(event.reminderDaysBefore)天就到「\(event.name)」了"
        content.sound = .default

        let calendar = Calendar.current
        guard let notifyDate = calendar.date(byAdding: .day,
                                             value: -event.reminderDaysBefore,
                                             to: event.targetDate) else { return }
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute],
                                                 from: notifyDate)
        // Set to 9:00 AM
        var triggerComponents = components
        triggerComponents.hour = 9
        triggerComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(identifier: event.id.uuidString,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelNotification(for event: CountdownEvent) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [event.id.uuidString]
        )
    }
}
