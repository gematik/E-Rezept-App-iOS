//
//  Copyright (c) 2021 gematik GmbH
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

/// Interface to access user specific data
/// sourcery: StreamWrapped
public protocol UserDataStore: AnyObject {
    /// Indicates if the onboarding screens should be displayed
    var hideOnboarding: AnyPublisher<Bool, Never> { get }

    /// Set the hideOnboarding
    /// The new value is published through `hideOnboarding`
    /// - Parameter hideOnboarding: `true`if it should be hidden, otherwise `false`
    func set(hideOnboarding: Bool)

    /// Indicates if the card wall intro screen should be displayed
    var hideCardWallIntro: AnyPublisher<Bool, Never> { get }

    /// Set the hideCardWallIntro
    /// The new value is published through `hideCardWallIntro`
    /// - Parameter hideCardWallIntro: `true`if it should be hidden, otherwise `false`
    func set(hideCardWallIntro: Bool)

    /// Server environment name to use. Only available in non production builds.
    func set(serverEnvironmentConfiguration: String?)

    /// Server environment name to use. Only available in non production builds.
    var serverEnvironmentConfiguration: AnyPublisher<String?, Never> { get }

    /// The app security option
    var appSecurityOption: AnyPublisher<Int, Never> { get }

    /// Set the app security option
    /// The new value is published through `appSecurityOption`
    /// - Parameter appSecurityOption:The option selected to secure the app
    func set(appSecurityOption: Int)
}
