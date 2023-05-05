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
import Foundation
import UIKit

struct AccessibilityAnnouncementReceiver {
    var accessibilityAnnouncement: (String) -> Void
}

// MARK: TCA Dependency

extension AccessibilityAnnouncementReceiver: DependencyKey {
    public static let liveValue = AccessibilityAnnouncementReceiver { message in
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    public static let previewValue: AccessibilityAnnouncementReceiver = .init { _ in }

    public static let testValue: AccessibilityAnnouncementReceiver = .init(accessibilityAnnouncement: unimplemented())
}

extension DependencyValues {
    var accessibilityAnnouncementReceiver: AccessibilityAnnouncementReceiver {
        get { self[AccessibilityAnnouncementReceiver.self] }
        set { self[AccessibilityAnnouncementReceiver.self] = newValue }
    }
}
