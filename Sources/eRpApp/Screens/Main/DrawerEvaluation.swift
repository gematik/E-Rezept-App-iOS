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

@DependencyClient
struct DrawerEvaluation {
    var showDrawerEvaluation: () async -> DrawerEvaluationResult = { .none }

    enum DrawerEvaluationResult {
        case welcomeDrawer
        case consentDrawer
        case none
    }
}

extension DrawerEvaluation: DependencyKey {
    static var liveValue: DrawerEvaluation = .init {
        @Dependency(\.userSession) var userSession: UserSession
        @Dependency(\.chargeItemConsentService) var chargeItemConsentService: ChargeItemConsentService

        do {
            let profile = try await userSession.profile().async(\MainDomain.Error.Cases.localStoreError)
            // show welcome drawer?
            if profile.insuranceType == .unknown,
               profile.hideWelcomeDrawerOnMainView == false {
                return .welcomeDrawer
            }

            // show consent drawer?
            if profile.insuranceType == .pKV,
               profile.hidePkvConsentDrawerOnMainView == false,
               // Only if the service responded successfully that the consent has not been granted yet
               // (== .success(false)) we want to show the consent drawer. Otherwise we don't.
               case .notGranted = try await chargeItemConsentService.checkForConsent(profile.id) {
                return .consentDrawer
            }
        } catch {
            // fall-through in case of any error
        }

        return .none
    }

    static var testValue: DrawerEvaluation = .init {
        .none
    }
}

// MARK: TCA Dependency

struct DrawerEvaluationDependency: DependencyKey {
    static let liveValue: DrawerEvaluation = .liveValue

    static let previewValue: DrawerEvaluation = .liveValue

    static let testValue: DrawerEvaluation = .testValue
}

extension DependencyValues {
    var drawerEvaluation: DrawerEvaluation {
        get { self[DrawerEvaluationDependency.self] }
        set { self[DrawerEvaluationDependency.self] = newValue }
    }
}
