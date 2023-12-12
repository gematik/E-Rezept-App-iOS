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
