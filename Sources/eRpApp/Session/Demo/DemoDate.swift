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

/// Creates formatted dates (authoredOn, expiresOn) for demo data
enum DemoDate: CaseIterable {
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

    // swiftlint:disable:next cyclomatic_complexity
    static func createDemoDate(_ authoredDate: DemoDate) -> String? {
        let aDate: Date
        switch authoredDate {
        case .ninetyTwoDaysBefore:
            aDate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 92)
        case .thirtyDaysBefore:
            aDate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 30)
        case .sixteenDaysBefore:
            aDate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 16)
        case .weekBefore:
            aDate = Date(timeIntervalSinceNow: -60 * 60 * (24 * 7 + 2)) // Extra 2h to account for summer-/wintertime
        case .dayBeforeYesterday:
            aDate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 2)
        case .yesterday:
            aDate = Date(timeIntervalSinceNow: -60 * 60 * 24)
        case .oneHourAgo:
            aDate = Date(timeIntervalSinceNow: -60 * 60)
        case .today:
            aDate = Date()
        case .tomorrow:
            aDate = Date(timeIntervalSinceNow: 60 * 60 * 24)
        case .dayAfterTomorrow:
            aDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 2)
        case .threeDaysAhead:
            aDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 3)
        case .twelveDaysAhead:
            aDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 12)
        case .twentyEightDaysAhead:
            aDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 28)
        case .ninetyTwoDaysAhead:
            aDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 92)
        }
        return FHIRDateFormatter.liveValue
            .stringWithLongUTCTimeZone(from: aDate)
    }
}
