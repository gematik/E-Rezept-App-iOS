//
//  Copyright (c) 2024 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//

import Dependencies
@testable import eRpApp
import eRpKit
import Nimble
import UserNotifications
import XCTest

final class NotificationSchedulerTests: XCTestCase {
    static let calendar = Calendar.current
    func testNotificationsFromSchedules() {
        // given
        let schedules = [
            Self.Fixtures.medicationScheduleOneEntry,
            Self.Fixtures.medicationScheduleTwoEntriesTwoDays,
            Self.Fixtures.medicationScheduleOneEntryEndDistantFuture,
            Self.Fixtures.medicationScheduleInactive,
        ]
        let uuid = UUIDGenerator.incrementing

        // when
        let notifications = NotificationScheduler.from(
            schedules: schedules,
            calendar: Self.calendar,
            uuid: uuid
        )

        // then
        expect(notifications.count) == 6
    }

    func testNotificationsFromInactiveSchedule() {
        // given
        let uuid = UUIDGenerator.incrementing

        // when
        let notifications = NotificationScheduler.from(
            schedules: [Self.Fixtures.medicationScheduleInactive],
            calendar: Self.calendar,
            uuid: uuid
        )

        // then
        expect(notifications.count) == 0
    }

    func testRequestCreator_triggerRepeating() {
        // given
        let oneEntryDistantFuture = Self.Fixtures.medicationScheduleOneEntryEndDistantFuture
        let uuid = UUIDGenerator.incrementing

        // when
        let notificationsFromOneEntry = NotificationScheduler.Request.Creator.oneNotificationRequestForEachEntry(
            schedule: oneEntryDistantFuture,
            calendar: Self.calendar,
            uuid: uuid
        )

        // then
        guard let notification = notificationsFromOneEntry.first,
              let trigger = notification.trigger as? UNCalendarNotificationTrigger
        else {
            Nimble.fail("Expected at least one Notification or malformed trigger")
            return
        }

        expect(notification.identifier) == "00000000-0000-0000-0000-000000000000"

        expect(trigger.repeats) == true

        expect(trigger.dateComponents.year).to(beNil())
        expect(trigger.dateComponents.month).to(beNil())
        expect(trigger.dateComponents.day).to(beNil())
        expect(trigger.dateComponents.hour) == oneEntryDistantFuture.entries.first!.hourComponent
        expect(trigger.dateComponents.minute) == oneEntryDistantFuture.entries.first!.minuteComponent

        expect(trigger.nextTriggerDate()).toNot(beNil())
    }

    func testRequestCreator_triggerNonRepeating() {
        // given
        let oneEntry = Self.Fixtures.medicationScheduleOneEntry
        let uuid = UUIDGenerator.incrementing

        // when
        let notificationRequestsFromOneEntry = NotificationScheduler.Request.Creator.oneNotificationRequestForEachEntry(
            schedule: oneEntry,
            calendar: Self.calendar,
            uuid: uuid
        )

        // then
        guard let notificationRequest = notificationRequestsFromOneEntry.first,
              let trigger = notificationRequest.trigger as? UNCalendarNotificationTrigger
        else {
            Nimble.fail("Expected at least one Notification or malformed trigger")
            return
        }

        expect(notificationRequest.identifier) == "00000000-0000-0000-0000-000000000000"

        expect(trigger.repeats) == false

        expect(trigger.dateComponents.year) == Self.calendar.component(.year, from: oneEntry.start)
        expect(trigger.dateComponents.month) == Self.calendar.component(.month, from: oneEntry.start)
        expect(trigger.dateComponents.day) == Self.calendar.component(.day, from: oneEntry.start)
        expect(trigger.dateComponents.hour) == oneEntry.entries.first!.hourComponent
        expect(trigger.dateComponents.minute) == oneEntry.entries.first!.minuteComponent

        expect(trigger.nextTriggerDate()).toNot(beNil())
    }

    func testRequestCreator_triggerNonRepeatingInThePast() {
        let uuid = UUIDGenerator.incrementing

        let oneEntryInThePast = Self.Fixtures.medicationScheduleOneEntryInThePast
        let notificationsFromOneEntry = NotificationScheduler.Request.Creator.oneNotificationRequestForEachEntry(
            schedule: oneEntryInThePast,
            calendar: Self.calendar,
            uuid: uuid
        )
        guard let notification = notificationsFromOneEntry.first,
              let trigger = notification.trigger as? UNCalendarNotificationTrigger
        else {
            Nimble.fail("Expected at least one Notification or malformed trigger")
            return
        }

        expect(notification.identifier) == "00000000-0000-0000-0000-000000000000"
        expect(trigger.repeats) == false
        expect(trigger.nextTriggerDate()).to(beNil())
    }

    func testRequestCreator_count() {
        let uuid = UUIDGenerator.incrementing

        let oneEntry = Self.Fixtures.medicationScheduleOneEntry
        expect(NotificationScheduler.Request.Creator.oneNotificationRequestForEachEntry(
            schedule: oneEntry,
            calendar: Self.calendar,
            uuid: uuid
        ).count) == 1

        let oneEntryEndDistantFuture = Self.Fixtures.medicationScheduleOneEntryEndDistantFuture
        expect(NotificationScheduler.Request.Creator.oneNotificationRequestForEachEntry(
            schedule: oneEntryEndDistantFuture,
            calendar: Self.calendar,
            uuid: uuid
        ).count) == 1

        let twoEntries = Self.Fixtures.medicationScheduleTwoEntries
        expect(NotificationScheduler.Request.Creator.oneNotificationRequestForEachEntry(
            schedule: twoEntries,
            calendar: Self.calendar,
            uuid: uuid
        ).count) == 2

        let twoEntriesTwoDays = Self.Fixtures.medicationScheduleTwoEntriesTwoDays
        expect(NotificationScheduler.Request.Creator.oneNotificationRequestForEachEntry(
            schedule: twoEntriesTwoDays,
            calendar: Self.calendar,
            uuid: uuid
        ).count) == 4
    }
}

extension NotificationSchedulerTests {
    enum Fixtures {
        static let now = Date.now
        static let calendar = Calendar.current
        static let oneHourLater = now.addingTimeInterval(60)
        static let medicationScheduleOneEntry: MedicationSchedule = {
            MedicationSchedule(
                id: UUID(),
                start: now,
                end: now,
                title: "",
                dosageInstructions: "",
                taskId: "taskId1",
                isActive: true,
                entries: [
                    .init(
                        id: UUID(),
                        title: "oneEntryFirstEntry",
                        hourComponent: calendar.component(.hour, from: oneHourLater),
                        minuteComponent: calendar.component(.minute, from: oneHourLater),
                        dosageForm: "pill",
                        amount: "1"
                    ),
                ]
            )
        }()

        static let medicationScheduleOneEntryEndDistantFuture: MedicationSchedule = {
            MedicationSchedule(
                id: UUID(),
                start: now,
                end: Date.distantFuture,
                title: "",
                dosageInstructions: "",
                taskId: "taskId1",
                isActive: true,
                entries: [
                    .init(
                        id: UUID(),
                        title: "oneEntryFirstEntry",
                        hourComponent: calendar.component(.hour, from: oneHourLater),
                        minuteComponent: calendar.component(.minute, from: oneHourLater),
                        dosageForm: "pill",
                        amount: "1"
                    ),
                ]
            )
        }()

        static let oneHourEarlier = now.addingTimeInterval(-60)
        static let medicationScheduleOneEntryInThePast: MedicationSchedule = {
            MedicationSchedule(
                id: UUID(),
                start: now,
                end: now,
                title: "",
                dosageInstructions: "",
                taskId: "taskId1",
                isActive: true,
                entries: [
                    .init(
                        id: UUID(),
                        title: "oneEntryFirstEntry",
                        hourComponent: calendar.component(.hour, from: oneHourEarlier),
                        minuteComponent: calendar.component(.minute, from: oneHourEarlier),
                        dosageForm: "pill",
                        amount: "1"
                    ),
                ]
            )
        }()

        static let twoHoursLater = now.addingTimeInterval(60 * 2)
        static let medicationScheduleTwoEntries: MedicationSchedule = {
            MedicationSchedule(
                id: UUID(),
                start: now,
                end: now,
                title: "",
                dosageInstructions: "",
                taskId: "taskId2",
                isActive: true,
                entries: [
                    .init(
                        id: UUID(),
                        title: "twoEntriesFirstEntry",
                        hourComponent: calendar.component(.hour, from: oneHourLater),
                        minuteComponent: calendar.component(.minute, from: oneHourLater),
                        dosageForm: "pill",
                        amount: "1"
                    ),
                    .init(
                        id: UUID(),
                        title: "twoEntriesSecondEntry",
                        hourComponent: calendar.component(.hour, from: twoHoursLater),
                        minuteComponent: calendar.component(.minute, from: twoHoursLater),
                        dosageForm: "pill",
                        amount: "2"
                    ),
                ]
            )
        }()

        static let medicationScheduleTwoEntriesTwoDays: MedicationSchedule = {
            MedicationSchedule(
                id: UUID(),
                start: now,
                end: now.advanced(by: 60 * 60 * 24),
                title: "",
                dosageInstructions: "",
                taskId: "taskId2",
                isActive: true,
                entries: [
                    .init(
                        id: UUID(),
                        title: "twoEntriesFirstEntry",
                        hourComponent: calendar.component(.hour, from: oneHourLater),
                        minuteComponent: calendar.component(.minute, from: oneHourLater),
                        dosageForm: "pill",
                        amount: "1"
                    ),
                    .init(
                        id: UUID(),
                        title: "twoEntriesSecondEntry",
                        hourComponent: calendar.component(.hour, from: twoHoursLater),
                        minuteComponent: calendar.component(.minute, from: twoHoursLater),
                        dosageForm: "pill",
                        amount: "2"
                    ),
                ]
            )
        }()

        static let medicationScheduleInactive: MedicationSchedule = {
            MedicationSchedule(
                id: UUID(),
                start: now,
                end: now,
                title: "",
                dosageInstructions: "",
                taskId: "taskId3",
                isActive: false,
                entries: [
                    .init(
                        id: UUID(),
                        title: "oneEntryFirstEntry",
                        hourComponent: calendar.component(.hour, from: oneHourLater),
                        minuteComponent: calendar.component(.minute, from: oneHourLater),
                        dosageForm: "pill",
                        amount: "3"
                    ),
                ]
            )
        }()
    }

    private static func roundDownToMinute(_ date: Date) -> Date {
        Date(timeIntervalSinceReferenceDate: (date.timeIntervalSinceReferenceDate / 60.0).rounded(.down) * 60.0)
    }
}
