//
//  Copyright (c) 2023 gematik GmbH
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

import Foundation

/// Creates formatted dates (authoredOn, expiresOn) for demo data
enum DemoDate: CaseIterable {
    case ninetyTwoDaysBefore
    case thirtyDaysBefore
    case sixteenDaysBefore
    case weekBefore
    case dayBeforeYesterday
    case yesterday
    case today
    case tomorrow
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
            aDate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 7)
        case .dayBeforeYesterday:
            aDate = Date(timeIntervalSinceNow: -60 * 60 * 24 * 2)
        case .yesterday:
            aDate = Date(timeIntervalSinceNow: -60 * 60 * 24)
        case .today:
            aDate = Date()
        case .tomorrow:
            aDate = Date(timeIntervalSinceNow: 60 * 60 * 24)
        case .twelveDaysAhead:
            aDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 12)
        case .twentyEightDaysAhead:
            aDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 28)
        case .ninetyTwoDaysAhead:
            aDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 92)
        }
        return globals.fhirDateFormatter
            .stringWithLongUTCTimeZone(from: aDate)
    }
}
