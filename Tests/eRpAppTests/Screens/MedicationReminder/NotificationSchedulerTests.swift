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
@testable import eRpFeatures
import eRpKit
import Nimble
import UserNotifications
import XCTest

final class NotificationSchedulerTests: XCTestCase {
    static let calendar = Calendar.current

    func testNotificationsFromSchedulesAllWeekdays() {
        // given
        let schedules = [
            Self.Fixtures.medicationScheduleOneEntryAllWeekdays,
            Self.Fixtures.medicationScheduleTwoEntriesEndsInTwoDaysAllWeekdays,
            Self.Fixtures.medicationScheduleOneEntryEndDistantFutureAllWeekdays,
            Self.Fixtures.medicationScheduleInactiveAllWeekdays,
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

    func testNotificationsFromInactiveScheduleAllWeekdays() {
        // given
        let uuid = UUIDGenerator.incrementing

        // when
        let notifications = NotificationScheduler.from(
            schedules: [Self.Fixtures.medicationScheduleInactiveAllWeekdays],
            calendar: Self.calendar,
            uuid: uuid
        )

        // then
        expect(notifications.count) == 0
    }

    func testRequestCreator_triggerRepeatingAllWeekdays() {
        // given
        let oneEntryDistantFuture = Self.Fixtures.medicationScheduleOneEntryEndDistantFutureAllWeekdays
        let uuid = UUIDGenerator.incrementing

        // when
        let notificationsFromOneEntry = NotificationScheduler.Request.Creator
            .oneNotificationRequestForEachEntryAccountingForWeekdaySelection(
                schedule: oneEntryDistantFuture,
                calendar: Self.calendar,
                uuid: uuid
            )

        // then
        guard let notification = notificationsFromOneEntry.first,
              let trigger = notification.trigger as? UNCalendarNotificationTrigger
        else {
            Nimble.fail("Expected at least one Notification and corresponding trigger")
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

    func testRequestCreator_triggerNonRepeatingAllWeekdays() {
        // given
        let oneEntry = Self.Fixtures.medicationScheduleOneEntryAllWeekdays
        let uuid = UUIDGenerator.incrementing

        // when
        let notificationRequestsFromOneEntry = NotificationScheduler.Request.Creator
            .oneNotificationRequestForEachEntryAccountingForWeekdaySelection(
                schedule: oneEntry,
                calendar: Self.calendar,
                uuid: uuid
            )

        // then
        guard let notificationRequest = notificationRequestsFromOneEntry.first,
              let trigger = notificationRequest.trigger as? UNCalendarNotificationTrigger
        else {
            Nimble.fail("Expected at least one Notification and corresponding trigger")
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

    func testRequestCreator_triggerNonRepeatingInThePastAllWeekdays() {
        let uuid = UUIDGenerator.incrementing

        let oneEntryInThePast = Self.Fixtures.medicationScheduleOneEntryInThePastAllWeekdays
        let notificationsFromOneEntry = NotificationScheduler.Request.Creator
            .oneNotificationRequestForEachEntryAccountingForWeekdaySelection(
                schedule: oneEntryInThePast,
                calendar: Self.calendar,
                uuid: uuid
            )
        guard let notification = notificationsFromOneEntry.first,
              let trigger = notification.trigger as? UNCalendarNotificationTrigger
        else {
            Nimble.fail("Expected at least one Notification and corresponding trigger")
            return
        }

        expect(notification.identifier) == "00000000-0000-0000-0000-000000000000"
        expect(trigger.repeats) == false
        expect(trigger.nextTriggerDate()).to(beNil())
    }

    func testRequestCreator_countAllWeekdays() {
        let uuid = UUIDGenerator.incrementing

        let oneEntry = Self.Fixtures.medicationScheduleOneEntryAllWeekdays
        expect(NotificationScheduler.Request.Creator.oneNotificationRequestForEachEntryAccountingForWeekdaySelection(
            schedule: oneEntry,
            calendar: Self.calendar,
            uuid: uuid
        ).count) == 1

        let oneEntryEndDistantFuture = Self.Fixtures.medicationScheduleOneEntryEndDistantFutureAllWeekdays
        expect(NotificationScheduler.Request.Creator.oneNotificationRequestForEachEntryAccountingForWeekdaySelection(
            schedule: oneEntryEndDistantFuture,
            calendar: Self.calendar,
            uuid: uuid
        ).count) == 1

        let twoEntries = Self.Fixtures.medicationScheduleTwoEntriesAllWeekdays
        expect(NotificationScheduler.Request.Creator.oneNotificationRequestForEachEntryAccountingForWeekdaySelection(
            schedule: twoEntries,
            calendar: Self.calendar,
            uuid: uuid
        ).count) == 2

        let twoEntriesTwoDays = Self.Fixtures.medicationScheduleTwoEntriesEndsInTwoDaysAllWeekdays
        expect(NotificationScheduler.Request.Creator.oneNotificationRequestForEachEntryAccountingForWeekdaySelection(
            schedule: twoEntriesTwoDays,
            calendar: Self.calendar,
            uuid: uuid
        ).count) == 4
    }

    func testRequestCreator_triggerRepeatingWeekdaysOnly() {
        // given
        let oneEntry = Self.Fixtures.medicationScheduleEndsInTwoWeeksMondaysOnly
        let uuid = UUIDGenerator.incrementing

        // when
        let notificationsFromOneEntry = NotificationScheduler.Request.Creator
            .oneNotificationRequestForEachEntryAccountingForWeekdaySelection(
                schedule: oneEntry,
                calendar: Self.calendar,
                uuid: uuid
            )

        // then
        guard let notification = notificationsFromOneEntry.first,
              let trigger: UNCalendarNotificationTrigger = notification.trigger as? UNCalendarNotificationTrigger
        else {
            Nimble.fail("Expected at least one Notification and corresponding trigger")
            return
        }

        expect(notification.identifier) == "00000000-0000-0000-0000-000000000000"

        expect(trigger.repeats) == false

        expect(trigger.dateComponents.year).to(equal(2025))
        expect(trigger.dateComponents.month).to(equal(4))
        expect(trigger.dateComponents.day).to(equal(21))
        expect(trigger.dateComponents.hour) == oneEntry.entries.first!.hourComponent
        expect(trigger.dateComponents.minute) == oneEntry.entries.first!.minuteComponent
        expect(trigger.dateComponents.weekday).to(beNil())
        expect(trigger.nextTriggerDate()).to(beNil())

        // A notification for Monday the week after was also requested
        let notification2 = notificationsFromOneEntry[1]
        guard let trigger2: UNCalendarNotificationTrigger = notification2.trigger as? UNCalendarNotificationTrigger
        else {
            Nimble.fail("Expected at least one Notification and corresponding trigger")
            return
        }
        expect(notification2.identifier) == "00000000-0000-0000-0000-000000000001"
        expect(trigger2.repeats) == false
        expect(trigger2.dateComponents.year).to(equal(2025))
        expect(trigger2.dateComponents.month).to(equal(4))
        expect(trigger2.dateComponents.day).to(equal(28))
        expect(trigger2.dateComponents.hour) == oneEntry.entries.first!.hourComponent
        expect(trigger2.dateComponents.minute) == oneEntry.entries.first!.minuteComponent
        expect(trigger2.dateComponents.weekday).to(beNil())
        expect(trigger2.nextTriggerDate()).to(beNil())
    }
}

extension NotificationSchedulerTests {
    enum Fixtures {
        static let now = Date.now
        static let calendar = Calendar.current
        static let oneHourLater = now.addingTimeInterval(60)
        static let medicationScheduleOneEntryAllWeekdays: MedicationSchedule = {
            MedicationSchedule(
                id: UUID(),
                start: now,
                end: now,
                title: "",
                dosageInstructions: "",
                taskId: "taskId1",
                isActive: true,
                weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
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

        static let medicationScheduleOneEntryEndDistantFutureAllWeekdays: MedicationSchedule = {
            MedicationSchedule(
                id: UUID(),
                start: now,
                end: Date.distantFuture,
                title: "",
                dosageInstructions: "",
                taskId: "taskId1",
                isActive: true,
                weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
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
        static let medicationScheduleOneEntryInThePastAllWeekdays: MedicationSchedule = {
            MedicationSchedule(
                id: UUID(),
                start: now,
                end: now,
                title: "",
                dosageInstructions: "",
                taskId: "taskId1",
                isActive: true,
                weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
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
        static let medicationScheduleTwoEntriesAllWeekdays: MedicationSchedule = {
            MedicationSchedule(
                id: UUID(),
                start: now,
                end: now,
                title: "",
                dosageInstructions: "",
                taskId: "taskId2",
                isActive: true,
                weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
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

        static let medicationScheduleTwoEntriesEndsInTwoDaysAllWeekdays: MedicationSchedule = {
            MedicationSchedule(
                id: UUID(),
                start: now,
                end: now.advanced(by: 60 * 60 * 24),
                title: "",
                dosageInstructions: "",
                taskId: "taskId2",
                isActive: true,
                weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
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

        static let medicationScheduleInactiveAllWeekdays: MedicationSchedule = {
            MedicationSchedule(
                id: UUID(),
                start: now,
                end: now,
                title: "",
                dosageInstructions: "",
                taskId: "taskId3",
                isActive: false,
                weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
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

        static let fixedData = Date(timeIntervalSinceReferenceDate: 766_565_081) // 2025-04-17 06:44:24 UTC
        static let medicationScheduleEndsInTwoWeeksMondaysOnly: MedicationSchedule = {
            MedicationSchedule(
                id: UUID(),
                start: Self.fixedData,
                end: Self.fixedData.advanced(by: 60 * 60 * 24 * 15),
                title: "",
                dosageInstructions: "",
                taskId: "taskId4",
                isActive: true,
                weekdays: [.monday],
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
