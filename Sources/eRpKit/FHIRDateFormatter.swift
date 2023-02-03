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

/// `DateFormatter` that should be used to parse FHIR  date strings into dates and vice versa
public class FHIRDateFormatter {
    /// Default initializer to create an instance of `FHIRDateFormatter`
    public static let shared = FHIRDateFormatter()
    private init() {}

    private lazy var serverDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()

    private lazy var utcDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()

    /// Creates a `String` representative of the passed `Date` that is ideal to use for server communication
    /// since it used the `ISO8601DateFormatter`.
    /// - Parameters:
    ///   - date: the `Date` which will be converted into a date string
    ///   - format: specify how detailed the format should be. The format can be one of the FHIR dates
    /// - Returns: a FHIR date string in the specified format
    public func string(from date: Date, format: DateFormats = .yearMonthDayTime) -> String {
        serverDateFormatter.formatOptions = format.formatOptions
        return serverDateFormatter.string(from: date)
    }

    /// Creates a `Date` from a string if it conforms to one of the FHIR date formats
    /// `YYYY, YYYY-MM, YYYY-MM-DD or YYYY-MM-DDThh:mm:ss+zz:zz`
    ///	https://www.hl7.org/fhir/datatypes.html
    ///
    ///	The method is idle to convert a date string from a server response since it used the `ISO8601DateFormatter`.
    ///
    /// - Parameters:
    ///   - string: a date string in one of the valid date FHIR formats or the one `format` defined explicit
    ///   - format: the date `format` off the string which should be used to evaluate the string. Pass `nil` if
    ///   the method should find the correct FHIR format.
    /// - Returns: a `Date` constructed from the `string` if the format was correct, otherwise `nil`
    public func date(from string: String, format: DateFormats? = nil) -> Date? {
        guard let dateFormat = format ?? dateFormat(for: string) else {
            return nil
        }

        serverDateFormatter.formatOptions = dateFormat.formatOptions
        return serverDateFormatter.date(from: string)
    }

    /// Creates a date string with the format `2020-06-23T09:41:00+00:00`
    /// this format is currently used by the FHIR server
    /// - Parameter date: the `Date` which will be converted into a date string
    /// - Returns: a FHIR date string with a time zone `UTC` in form `+00:00`
    public func stringWithLongUTCTimeZone(from date: Date) -> String {
        utcDateFormatter.dateFormat = DateFormats.yearMonthDayTime.format
        return utcDateFormatter.string(from: date)
    }

    private func dateFormat(for string: String) -> DateFormats? {
        // allowed FHIR formats are: YYYY, YYYY-MM, YYYY-MM-DD or YYYY-MM-DDThh:mm:ss+zz:zz
        DateFormats.allCases.first { string.range(of: $0.regex, options: .regularExpression) != nil }
    }
}

extension FHIRDateFormatter {
    public enum DateFormats: CaseIterable {
        case year
        case yearMonth
        case yearMonthDay
        case yearMonthDayTime
        case yearMonthDayTimeMilliSeconds

        var format: String {
            switch self {
            case .year: return "yyyy"
            case .yearMonth: return "yyyy-MM"
            case .yearMonthDay: return "yyyy-MM-dd"
            case .yearMonthDayTime: return "yyyy-MM-dd'T'HH:mm:ssxxx" // 'xxx' generates a timezone in form of '+00:00'
            case .yearMonthDayTimeMilliSeconds: return "yyyy-MM-dd'T'HH:mm:ss.SSSxxx"
            }
        }

        var formatOptions: ISO8601DateFormatter.Options {
            switch self {
            case .year: return [.withYear, .withDashSeparatorInDate]
            case .yearMonth: return [.withYear, .withMonth, .withDashSeparatorInDate]
            case .yearMonthDay: return [.withFullDate, .withDashSeparatorInDate]
            case .yearMonthDayTime: return .withInternetDateTime
            case .yearMonthDayTimeMilliSeconds: return [.withInternetDateTime, .withFractionalSeconds]
            }
        }

        var regex: String {
            switch self {
            case .year: return "^(\\d{4})$"
            case .yearMonth: return "^(\\d{4}-\\d{2})$"
            case .yearMonthDay: return "^(\\d{4}-\\d{2}-\\d{2})$"
            case .yearMonthDayTime: return "^(\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}[+-]\\d{2}:\\d{2})$"
            case .yearMonthDayTimeMilliSeconds:
                return "^(\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.[0-9]+[+-]\\d{2}:\\d{2})$"
            }
        }
    }
}

extension Date {
    /// Returns a date formatted String that can be used for server communication
    public var isoFormattedDateString: String {
        FHIRDateFormatter.shared.string(from: self)
    }

    /// Returns a date string in one of the allowed FHIR formats
    /// - Parameter format: date format that should be used
    /// - Returns: string representation of self in the specified `format`
    public func fhirFormattedString(with format: FHIRDateFormatter.DateFormats) -> String {
        FHIRDateFormatter.shared.string(from: self, format: format)
    }
}

extension String {
    /// Returns a `Date`  object of the corresponding FHIR date if it's format is within the allowed FHIR formats
    public var date: Date? {
        FHIRDateFormatter.shared.date(from: self)
    }
}
