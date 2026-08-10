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

/// Formats date strings from FHIR resources into user-friendly formats, including relative date and time formatting.
public struct UIDateFormatter {
    let fhirDateFormatter: FHIRDateFormatter

    /// Initializes a new instance of `UIDateFormatter` with the provided `FHIRDateFormatter`.
    public init(fhirDateFormatter: FHIRDateFormatter) {
        self.fhirDateFormatter = fhirDateFormatter
    }

    private var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = false
        return formatter
    }()

    private var relativeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    private var relativeTimeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.formattingContext = .beginningOfSentence
        return formatter
    }()

    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = false
        return formatter
    }()

    private var relativeDateAndTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    private var dateAndTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter
    }()

    /// Formats a date string into a compact format that includes both date and time, using the medium date style and
    /// short time style.
    public let compactDateAndTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    /// Formats a date string into a time-only format, using the short time style. For German locales, it appends "Uhr"
    /// to the time.
    public var timeOnlyFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        if let preferredLang = Locale.preferredLanguages.first,
           preferredLang.starts(with: "de") {
            dateFormatter.dateFormat = "HH:mm 'Uhr'"
        } else {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        }
        return dateFormatter
    }()

    /// Formats a date string into a relative date and time format, such as "today at 3:00 PM" or "yesterday at 5:00
    /// PM". If the input string cannot be parsed as a date, it returns the original string.
    public func relativeDateAndTime(_ string: String?) -> String? {
        if let dateTimeString = string,
           let dateTime = fhirDateFormatter.date(from: dateTimeString) {
            return relativeDateAndTime(from: dateTime)
        }
        return string
    }

    /// Formats a date into a relative date and time format, such as "today at 3:00 PM" or "yesterday at 5:00 PM".
    public func relativeDateAndTime(from date: Date) -> String {
        relativeDateAndTimeFormatter.string(from: date)
    }

    /// Formats a date string into a relative date format, such as "today", "yesterday", or "tomorrow". If the input
    /// string cannot be parsed as a date, it returns the original string.
    public func relativeDate(
        _ string: String?,
        formattingContext: RelativeDateTimeFormatter.Context = .beginningOfSentence
    ) -> String? {
        if let dateAsString = string,
           let date = fhirDateFormatter.date(from: dateAsString, format: .yearMonthDay) {
            return relativeDate(from: date, formattingContext: formattingContext)
        }
        return string
    }

    /// Formats a date into a relative date format, such as "today", "yesterday", or "tomorrow". The `formattingContext`
    /// parameter allows you to specify the context in which the relative date is used, which can affect the
    /// capitalization of the output string.
    public func relativeDate(
        from date: Date,
        formattingContext: RelativeDateTimeFormatter.Context = .beginningOfSentence
    ) -> String {
        relativeDateFormatter.formattingContext = formattingContext
        return relativeDateFormatter.string(from: date)
    }

    /// Formats a date string into a relative time format, such as "in 5 minutes" or "3 hours ago". If the input string
    /// cannot be parsed as a date, it returns the original string.
    public func relativeTime(from date: Date,
                             formattingContext: RelativeDateTimeFormatter.Context = .beginningOfSentence) -> String {
        @Dependency(\.date) var dateGenerator
        relativeTimeFormatter.formattingContext = formattingContext
        return relativeTimeFormatter.localizedString(for: date, relativeTo: dateGenerator())
    }

    /// Formats a date into a relative time format, such as "in 5 minutes" or "3 hours ago". The `formattingContext`
    /// parameter allows you to specify the context in which the relative time is used, which can affect the
    /// capitalization of the output string. If the input date is `nil`, it returns `nil`.
    public func relativeTime(from date: Date?,
                             formattingContext: RelativeDateTimeFormatter.Context = .beginningOfSentence) -> String? {
        @Dependency(\.date) var dateGenerator
        relativeTimeFormatter.formattingContext = formattingContext
        guard let date else { return nil }
        return relativeTimeFormatter.localizedString(for: date, relativeTo: dateGenerator())
    }

    /// Formats a date string into a time-only format, using the short time style. For German locales, it appends "Uhr"
    /// to the time. If the input string cannot be parsed as a date, it returns the original string.
    public func formattedTime(from date: Date) -> String {
        timeFormatter.string(from: date)
    }

    /// Formats a date string into a time-only format, using the short time style. For German locales, it appends "Uhr"
    /// to the time. If the input string cannot be parsed as a date, it returns the original string.
    public func date(_ string: String?) -> String? {
        if let dateAsString = string,
           let date = fhirDateFormatter.date(from: dateAsString, format: .yearMonthDay) {
            return dateFormatter.string(from: date)
        }
        return string
    }

    /// Formats a date string into a format that includes both date and time, using the "dd.MM.yyyy HH:mm" format. If
    /// the input string cannot be parsed as a date, it returns the original string.
    public func dateTime(_ string: String?) -> String? {
        if let dateAsString = string,
           let date = fhirDateFormatter.date(from: dateAsString, format: .yearMonthDayTime) {
            return dateAndTimeFormatter.string(from: date)
        }
        return string
    }

    /// Formats a date string into a format that includes both date and time, using the "dd.MM.yyyy HH:mm" format, and
    /// advances the date by a specified time interval. If the input string cannot be parsed as a date, it returns the
    /// original string.
    public func date(_ string: String?, advancedBy timeInterval: TimeInterval) -> String? {
        if let dateAsString = string,
           let date = fhirDateFormatter.date(from: dateAsString, format: .yearMonthDay) {
            return dateFormatter.string(from: date.advanced(by: timeInterval))
        }
        return string
    }
}

// MARK: TCA Dependency

extension UIDateFormatter: DependencyKey {
    public static var liveValue: UIDateFormatter = {
        @Dependency(\.fhirDateFormatter) var fhirDateFormatter
        return UIDateFormatter(fhirDateFormatter: fhirDateFormatter)
    }()

    public static var previewValue: UIDateFormatter = liveValue

    public static var testValue: UIDateFormatter = liveValue
}

extension DependencyValues {
    /// Formats date strings from FHIR resources into user-friendly formats, including relative date and time
    /// formatting.
    public var uiDateFormatter: UIDateFormatter {
        get { self[UIDateFormatter.self] }
        set { self[UIDateFormatter.self] = newValue }
    }
}
