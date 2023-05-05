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

import Dependencies
import eRpKit
import Foundation

struct UIDateFormatter {
    let fhirDateFormatter: FHIRDateFormatter

    init(fhirDateFormatter: FHIRDateFormatter) {
        self.fhirDateFormatter = fhirDateFormatter
    }

    private var relativeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
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

    func relativeDateAndTime(_ string: String?) -> String? {
        if let dateTimeString = string,
           let dateTime = fhirDateFormatter.date(from: dateTimeString, format: .yearMonthDayTimeMilliSeconds) {
            return relativeDateAndTime(from: dateTime)
        }
        return string
    }

    func relativeDateAndTime(from date: Date) -> String {
        relativeDateAndTimeFormatter.string(from: date)
    }

    func relativeDate(_ string: String?) -> String? {
        if let dateAsString = string,
           let date = fhirDateFormatter.date(from: dateAsString, format: .yearMonthDay) {
            return relativeDate(from: date)
        }
        return string
    }

    func relativeDate(from date: Date) -> String {
        relativeDateFormatter.string(from: date)
    }

    func date(_ string: String?) -> String? {
        if let dateAsString = string,
           let date = fhirDateFormatter.date(from: dateAsString, format: .yearMonthDay) {
            return dateFormatter.string(from: date)
        }
        return string
    }
}

// MARK: TCA Dependency

extension UIDateFormatter: DependencyKey {
    static var liveValue: UIDateFormatter = {
        @Dependency(\.fhirDateFormatter) var fhirDateFormatter
        return UIDateFormatter(fhirDateFormatter: fhirDateFormatter)
    }()

    static var previewValue: UIDateFormatter = {
        @Dependency(\.fhirDateFormatter) var fhirDateFormatter
        return UIDateFormatter(fhirDateFormatter: fhirDateFormatter)
    }()

    static var testValue: UIDateFormatter = {
        @Dependency(\.fhirDateFormatter) var fhirDateFormatter
        return UIDateFormatter(fhirDateFormatter: fhirDateFormatter)
    }()
}

extension DependencyValues {
    var uiDateFormatter: UIDateFormatter {
        get { self[UIDateFormatter.self] }
        set { self[UIDateFormatter.self] = newValue }
    }
}
