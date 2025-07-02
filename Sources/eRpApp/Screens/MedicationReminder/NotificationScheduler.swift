//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import Dependencies
import eRpKit
import Foundation
import UserNotifications

struct NotificationScheduler {
    var schedule: @Sendable ([MedicationSchedule]) async throws -> Void
    var cancelAllPendingRequests: @Sendable () async throws -> Void
    var removeDeliveredNotification: @Sendable (MedicationSchedule) async throws -> Void
    var requestAuthorization: @Sendable (UNAuthorizationOptions) async throws -> Bool
    var isAuthorized: @Sendable ()
        async -> Bool

    struct Notification: Equatable {
        var date: Date
        var request: UNNotificationRequest

        init(
            date: Date,
            request: UNNotificationRequest
        ) {
            self.date = date
            self.request = request
        }

        struct Response: Equatable {
            var notification: Notification

            init(notification: Notification) {
                self.notification = notification
            }
        }

        struct Settings: Equatable {
            var authorizationStatus: UNAuthorizationStatus

            init(authorizationStatus: UNAuthorizationStatus) {
                self.authorizationStatus = authorizationStatus
            }
        }
    }
}

struct ActiveNotificationSet {
    var notifications: [UNNotification]
    var referenceObjectId: UUID
}

extension NotificationScheduler: DependencyKey {
    static var liveValue: NotificationScheduler {
        let notificationCenter = UNUserNotificationCenter.current()
        @Dependency(\.calendar) var calendar
        @Dependency(\.uuid) var uuid

        return NotificationScheduler(
            schedule: { medicationSchedules in
                // Schedule the notifications of MedicationSchedule
                // At this point we assume that there are no pending notifications
                let notificationRequests = Self.from(
                    schedules: medicationSchedules,
                    calendar: calendar,
                    uuid: uuid
                )

                for reminderNotificationRequest in notificationRequests {
                    try await notificationCenter.add(reminderNotificationRequest)
                }
            },

            cancelAllPendingRequests: {
                notificationCenter.removeAllPendingNotificationRequests()
            },

            removeDeliveredNotification: { _ in
                // to be implemented
            },

            requestAuthorization: {
                try await notificationCenter.requestAuthorization(options: $0)
            },

            isAuthorized: {
                await notificationCenter.notificationSettings().authorizationStatus == .authorized
            }
        )
    }

    static let testValue = NotificationScheduler(
        schedule: unimplemented("schedule"),
        cancelAllPendingRequests: unimplemented("cancel"),
        removeDeliveredNotification: unimplemented("removeDeliveredNotification"),
        requestAuthorization: unimplemented("requestAuthorization"),
        isAuthorized: unimplemented("isAuthorized", placeholder: false)
    )
}

extension DependencyValues {
    var notificationScheduler: NotificationScheduler {
        get { self[NotificationScheduler.self] }
        set { self[NotificationScheduler.self] = newValue }
    }
}

extension NotificationScheduler {
    static func from(
        schedules: [MedicationSchedule],
        calendar: Calendar,
        uuid: UUIDGenerator
    ) -> [UNNotificationRequest] {
        // Create one notification per schedule per schedule's entry
        // If the schedule's end date is `distantFuture` then one (self-repeating) notification is created
        // If the schedule`s `isActive` is false it will be filtered out
        let oneRequestForEachScheduleEntry = schedules
            .filter(\.isActive)
            .flatMap { schedule in
                Request.Creator.oneNotificationRequestForEachEntryAccountingForWeekdaySelection(
                    schedule: schedule,
                    calendar: calendar,
                    uuid: uuid
                )
//                Request.Creator.oneNotificationRequestForEachEntry(
//                    schedule: schedule,
//                    calendar: calendar,
//                    uuid: uuid
//                )
            }

        // todomedicationReminder:
        // For now just return notifications for each `Entry` of every `MedicationSchedule`
        // Later merge/join them with each other according to a merging strategy (if times overlap, ...)

        // We want to prioritise the notifications with self-repeating trigger when scheduling:
//        let repeatingCount = oneNotificationRequestForEachScheduleEntry.partition(by: \.trigger?.repeats)

        //  merge(oneNotificationRequestForEachScheduleEntry, strategy: .identity)

        // since 64 notifications is the maximum that NotificationCenter accepts,
        // sort them by date (and cut off after 64) before adding
        return oneRequestForEachScheduleEntry
    }

    enum Request {
        enum Creator {
            // swiftlint:disable:next function_body_length
            static func oneNotificationRequestForEachEntryAccountingForWeekdaySelection(
                schedule: MedicationSchedule,
                calendar: Calendar,
                uuid: UUIDGenerator
            ) -> [UNNotificationRequest] {
                let content = UNMutableNotificationContent()
                content.title = L10n.medReminderTxtNotificationContentTitle.text
                content.body = schedule.title
                content.sound = .default

                content.threadIdentifier = "medication_schedule"

                let hasFiniteEndDate = schedule.end != Date.distantFuture
                let notificationRequests: [UNNotificationRequest] = schedule.entries
                    .flatMap { entry -> [UNNotificationRequest] in
                        content.userInfo = ["entries": [entry.id.uuidString]]

                        var requests = [UNNotificationRequest]()

                        if hasFiniteEndDate {
                            // Handle notifications for schedules with finite end date
                            let days = calendar.dateComponents([.day], from: schedule.start, to: schedule.end)
                            guard let dayCountUntilEndDate = days.day,
                                  dayCountUntilEndDate >= 0
                            else { return [] }

                            // 64 is the maximum that NotificationCenter accepts
                            for dayInterval in 0 ... min(dayCountUntilEndDate, 64) {
                                guard
                                    let notificationDay = calendar.date(
                                        byAdding: .day,
                                        value: dayInterval,
                                        to: schedule.start
                                    )
                                else { continue }
                                // Output is Sunday = 1, Monday = 2, Tuesday = 3, ...
                                let weekdayIndex = calendar.component(.weekday, from: notificationDay)
                                // Transform it to Monday = 1, Tuesday = 2, Wednesday = 3, ..., Sunday = 7
                                let transformedWeekdayIndexIndex = weekdayIndex == 1 ? 7 : weekdayIndex - 1
                                guard
                                    let weekday = MedicationSchedule.Weekday(rawValue: transformedWeekdayIndexIndex),
                                    schedule.weekdays.contains(weekday),
                                    let notificationDate = calendar.date(
                                        bySettingHour: entry.hourComponent,
                                        minute: entry.minuteComponent,
                                        second: 0,
                                        of: notificationDay
                                    )
                                else { continue }

                                let notificationDateComponents = calendar.dateComponents(
                                    [.year, .month, .day, .hour, .minute],
                                    from: notificationDate
                                )
                                let notificationTrigger = UNCalendarNotificationTrigger(
                                    dateMatching: notificationDateComponents,
                                    repeats: false
                                )
                                let identifier = uuid().uuidString
                                let request = UNNotificationRequest(
                                    identifier: identifier,
                                    content: content,
                                    trigger: notificationTrigger
                                )
                                requests.append(request)
                            }
                        } else {
                            // Handle repeating notifications for infinite schedules

                            // Check if all weekdays are selected
                            if schedule.weekdays.count == MedicationSchedule.Weekday.allCases.count {
                                // All weekdays selected -> create a single daily repeating notification

                                // Create a repeating trigger that fires daily at the specified time
                                let notificationTrigger = UNCalendarNotificationTrigger(
                                    dateMatching: DateComponents(
                                        calendar: calendar,
                                        hour: entry.hourComponent,
                                        minute: entry.minuteComponent
                                    ),
                                    repeats: true
                                )

                                // Create the notification request
                                let identifier = uuid().uuidString
                                let request = UNNotificationRequest(
                                    identifier: identifier,
                                    content: content,
                                    trigger: notificationTrigger
                                )

                                requests.append(request)
                            } else {
                                // Only specific weekdays selected - create a notification for each weekday
                                for weekday in schedule.weekdays {
                                    // Create date components for the trigger
                                    var dateComponents = DateComponents()
                                    dateComponents.calendar = calendar
                                    dateComponents.hour = entry.hourComponent
                                    dateComponents.minute = entry.minuteComponent

                                    // Convert Monday=1, Sunday=7 to Sunday=1, Saturday=7
                                    let calendarWeekday = weekday.rawValue == 7 ? 1 : weekday.rawValue + 1
                                    dateComponents.weekday = calendarWeekday

                                    // Create a repeating trigger for the specified weekday and time
                                    let notificationTrigger = UNCalendarNotificationTrigger(
                                        dateMatching: dateComponents,
                                        repeats: true
                                    )

                                    // Create the notification request
                                    let identifier = uuid().uuidString
                                    let request = UNNotificationRequest(
                                        identifier: identifier,
                                        content: content,
                                        trigger: notificationTrigger
                                    )

                                    requests.append(request)
                                }
                            }
                        }
                        return requests
                    }
                return notificationRequests
            }

            /// - Note: This function may create NotificationRequests
            ///  whose trigger's date (components) lays before the schedule's start date
            /// - Note: This function does not take into account the schedule's weekdays (and is therefore deprecated)
            static func oneNotificationRequestForEachEntry_depr(
                // swiftlint:disable:previous function_body_length
                schedule: MedicationSchedule,
                calendar: Calendar,
                uuid: UUIDGenerator
            ) -> [UNNotificationRequest] {
                let content = UNMutableNotificationContent()
                content.title = L10n.medReminderTxtNotificationContentTitle.text
                content.body = schedule.title
                content.sound = .default

                content.threadIdentifier = "medication_schedule"

                let hasFiniteEndDate = schedule.end != Date.distantFuture
                let notificationRequests: [UNNotificationRequest] = schedule.entries
                    .flatMap { entry -> [UNNotificationRequest] in
                        content.userInfo = ["entries": [entry.id.uuidString]]

                        var requests = [UNNotificationRequest]()

                        if hasFiniteEndDate {
                            let days = calendar.dateComponents([.day], from: schedule.start, to: schedule.end)
                            guard let dayCountUntilEndDate = days.day,
                                  dayCountUntilEndDate >= 0
                            else { return [] }

                            // 64 is the maximum that NotificationCenter accepts
                            for dayInterval in 0 ... min(dayCountUntilEndDate, 64) {
                                guard
                                    let notificationDay = calendar.date(
                                        byAdding: .day,
                                        value: dayInterval,
                                        to: schedule.start
                                    ),
                                    let notificationDate = calendar.date(
                                        bySettingHour: entry.hourComponent,
                                        minute: entry.minuteComponent,
                                        second: 0,
                                        of: notificationDay
                                    )
                                else { continue }

                                let notificationDateComponents = calendar.dateComponents(
                                    [.year, .month, .day, .hour, .minute],
                                    from: notificationDate
                                )
                                let notificationTrigger = UNCalendarNotificationTrigger(
                                    dateMatching: notificationDateComponents,
                                    repeats: false
                                )
                                let identifier = uuid().uuidString
                                let request = UNNotificationRequest(
                                    identifier: identifier,
                                    content: content,
                                    trigger: notificationTrigger
                                )
                                requests.append(request)
                            }
                        } else {
                            let trigger = UNCalendarNotificationTrigger(
                                dateMatching: DateComponents(
                                    calendar: calendar,
                                    hour: entry.hourComponent,
                                    minute: entry.minuteComponent
                                ),
                                repeats: true
                            )
                            let identifier = uuid().uuidString
                            requests = [
                                UNNotificationRequest(
                                    identifier: identifier,
                                    content: content,
                                    trigger: trigger
                                ),
                            ]
                        }
                        return requests
                    }
                return notificationRequests
            }
        }
    }
}

extension NotificationScheduler.Notification {
    init(rawValue: UNNotification) {
        date = rawValue.date
        request = rawValue.request
    }
}

extension NotificationScheduler.Notification.Response {
    init(rawValue: UNNotificationResponse) {
        notification = .init(rawValue: rawValue.notification)
    }
}

extension NotificationScheduler.Notification.Settings {
    init(rawValue: UNNotificationSettings) {
        authorizationStatus = rawValue.authorizationStatus
    }
}
