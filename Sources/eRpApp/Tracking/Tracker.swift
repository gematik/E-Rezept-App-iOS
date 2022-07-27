//
//  Copyright (c) 2022 gematik GmbH
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

import Combine
import Foundation

protocol Tracker: AnyObject {
    var optIn: Bool { get set }
    var optInPublisher: AnyPublisher<Bool, Never> { get }
}

class DummyTracker: Tracker {
    var optInPublisher: AnyPublisher<Bool, Never> {
        Just(optIn).eraseToAnyPublisher()
    }

    var optIn = false
}

class PlaceholderTracker: Tracker {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults

        // TODO: make sure these are true //swiftlint:disable:this todo
        // [REQ:gemSpec_eRp_FdV:A_19095] user session is randomly created - See visitorID.
        // [REQ:gemSpec_eRp_FdV:A_19096] new visitorID is generated when app is reinstalled.
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
