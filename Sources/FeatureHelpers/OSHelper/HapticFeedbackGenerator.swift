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
import DependenciesMacros
import Foundation
import UIKit

/// Generator for haptic feedback
@DependencyClient
public struct HapticFeedbackGenerator {
    /// Triggers a success haptic feedback
    public var success: () -> Void
}

extension HapticFeedbackGenerator: DependencyKey {
    /// Live implementation using UINotificationFeedbackGenerator
    public static var liveValue = Self {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    public static let previewValue = Self {}

    public static let testValue = Self()
}

extension DependencyValues {
    /// Access point for the HapticFeedbackGenerator dependency
    public var hapticFeedbackGenerator: HapticFeedbackGenerator {
        get { self[HapticFeedbackGenerator.self] }
        set { self[HapticFeedbackGenerator.self] = newValue }
    }
}
