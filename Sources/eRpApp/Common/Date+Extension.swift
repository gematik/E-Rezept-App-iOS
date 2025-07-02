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
import Foundation

extension Date {
    /// Calculates remaining days between self and a given date.
    ///
    /// - Parameters:
    ///   - date: the `date` to compare self with
    /// - Returns: number of days left to `date`. Returns a negative number if `date` lies in the past related to self
    func days(until date: Date) -> Int? {
        Date.days(from: self, to: date)
    }

    /// Calculates remaining days between two dates.
    ///
    /// - Parameters:
    ///   - start: date from which to calculate the remaining days to `end`
    ///   - end: date until which the `start` date will count the days
    ///   - calendar: calendar which is used
    /// - Returns: number of days left to `date`.
    /// 		   Returns a negative number  if `end` lies in the past related to `start`
    static func days(
        from start: Date,
        to end: Date,
        calendar: Calendar = Calendar.current
    ) -> Int? {
        let date1 = calendar.startOfDay(for: start)
        let date2 = calendar.startOfDay(for: end)

        return calendar.dateComponents([.day], from: date1, to: date2).day
    }
}
