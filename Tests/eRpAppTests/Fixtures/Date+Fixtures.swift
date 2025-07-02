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

import eRpKit
import Foundation

typealias TestDate = Date.Fixtures

extension Date {
    enum Fixtures {
        // Wednesday 2025-04-30 06:47:58 UTC
        static let defaultReferenceDate = Date(timeIntervalSinceReferenceDate: 767_688)

        enum LeapInTime: CaseIterable {
            case ninetyTwoDaysBefore
            case thirtyDaysBefore
            case sixteenDaysBefore
            case weekBefore
            case dayBeforeYesterday
            case yesterday
            case oneHourAgo
            case today
            case tomorrow
            case dayAfterTomorrow
            case threeDaysAhead
            case twelveDaysAhead
            case twentyEightDaysAhead
            case ninetyTwoDaysAhead
        }

        static func createFormattedDate(
            _ leapInTime: LeapInTime,
            referenceDate: Date? = nil,
            dateFormatter: @escaping (Date) -> String? = { date in
                FHIRDateFormatter.liveValue.stringWithLongUTCTimeZone(from: date)
            }
        ) -> String? {
            dateFormatter(Self.createDate(leapInTime, referenceDate: referenceDate))
        }

        // swiftlint:disable:next cyclomatic_complexity
        static func createDate(
            _ leapInTime: LeapInTime,
            referenceDate: Date? = nil
        ) -> Date {
            let referenceDate = referenceDate ?? defaultReferenceDate
            switch leapInTime {
            case .ninetyTwoDaysBefore:
                return referenceDate.addingTimeInterval(-60 * 60 * 24 * 92)
            case .thirtyDaysBefore:
                return referenceDate.addingTimeInterval(-60 * 60 * 24 * 30)
            case .sixteenDaysBefore:
                return referenceDate.addingTimeInterval(-60 * 60 * 24 * 16)
            case .weekBefore:
                return referenceDate.addingTimeInterval(-60 * 60 * (24 * 7))
            case .dayBeforeYesterday:
                return referenceDate.addingTimeInterval(-60 * 60 * 24 * 2)
            case .yesterday:
                return referenceDate.addingTimeInterval(-60 * 60 * 24)
            case .oneHourAgo:
                return referenceDate.addingTimeInterval(-60 * 60)
            case .today:
                return referenceDate
            case .tomorrow:
                return referenceDate.addingTimeInterval(60 * 60 * 24)
            case .dayAfterTomorrow:
                return referenceDate.addingTimeInterval(60 * 60 * 24 * 2)
            case .threeDaysAhead:
                return referenceDate.addingTimeInterval(60 * 60 * 24 * 3)
            case .twelveDaysAhead:
                return referenceDate.addingTimeInterval(60 * 60 * 24 * 12)
            case .twentyEightDaysAhead:
                return referenceDate.addingTimeInterval(60 * 60 * 24 * 28)
            case .ninetyTwoDaysAhead:
                return referenceDate.addingTimeInterval(60 * 60 * 24 * 92)
            }
        }
    }
}
