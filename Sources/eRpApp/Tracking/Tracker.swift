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

import Combine
import Dependencies
import Foundation

protocol Tracker: AnyObject {
    var optIn: Bool { get set }
    var optInPublisher: AnyPublisher<Bool, Never> { get }

    func track(events: [AnalyticsEvent])
    func track(screens: [AnalyticsScreen])
    func track(event: String)
    func track(screen: String)
    func stopTracking()
}

class DummyTracker: Tracker {
    var optInPublisher: AnyPublisher<Bool, Never> {
        Just(optIn).eraseToAnyPublisher()
    }

    var optIn = false

    func track(events _: [AnalyticsEvent]) {}
    func track(screens _: [AnalyticsScreen]) {}
    func track(event _: String) {}
    func track(screen _: String) {}
    func stopTracking() {}
}

class PlaceholderTracker: Tracker {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    var optIn: Bool {
        get {
            userDefaults.appTrackingAllowed
        }
        set {
            userDefaults.appTrackingAllowed = newValue
        }
    }

    var optInPublisher: AnyPublisher<Bool, Never> {
        userDefaults.publisher(for: \UserDefaults.appTrackingAllowed)
            .eraseToAnyPublisher()
    }

    func track(events _: [AnalyticsEvent]) {}
    func track(screens _: [AnalyticsScreen]) {}
    func track(event _: String) {}
    func track(screen _: String) {}
    func stopTracking() {
        optIn = false
    }
}

extension UserDefaults {
    /// Key for app tracking settings `UserDefaults`
    public static let kAppTrackingAllowed = "kAppTrackingAllowed"

    /// Store users setting for app tracking
    @objc public var appTrackingAllowed: Bool {
        get { bool(forKey: Self.kAppTrackingAllowed) }
        set { set(newValue, forKey: Self.kAppTrackingAllowed) }
    }
}

// MARK: TCA Dependency

struct TrackerDependency: DependencyKey {
    static let liveValue: Tracker = ContentSquareAnalyticsAdapter()

    static let previewValue: Tracker = DummyTracker()
}

extension DependencyValues {
    var tracker: Tracker {
        get { self[TrackerDependency.self] }
        set { self[TrackerDependency.self] = newValue }
    }
}
