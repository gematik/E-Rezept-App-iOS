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
@testable import eRpApp
import eRpKit
import Foundation
import IDP

// MARK: - MockProfileBasedSessionProvider -

final class MockProfileBasedSessionProvider: ProfileBasedSessionProvider {
    // MARK: - idpSession

    var idpSessionForCallsCount = 0
    var idpSessionForCalled: Bool {
        idpSessionForCallsCount > 0
    }

    var idpSessionForReceivedProfileId: UUID?
    var idpSessionForReceivedInvocations: [UUID] = []
    var idpSessionForReturnValue: IDPSession!
    var idpSessionForClosure: ((UUID) -> IDPSession)?

    func idpSession(for profileId: UUID) -> IDPSession {
        idpSessionForCallsCount += 1
        idpSessionForReceivedProfileId = profileId
        idpSessionForReceivedInvocations.append(profileId)
        return idpSessionForClosure.map { $0(profileId) } ?? idpSessionForReturnValue
    }

    // MARK: - biometrieIdpSession

    var biometrieIdpSessionForCallsCount = 0
    var biometrieIdpSessionForCalled: Bool {
        biometrieIdpSessionForCallsCount > 0
    }

    var biometrieIdpSessionForReceivedProfileId: UUID?
    var biometrieIdpSessionForReceivedInvocations: [UUID] = []
    var biometrieIdpSessionForReturnValue: IDPSession!
    var biometrieIdpSessionForClosure: ((UUID) -> IDPSession)?

    func biometrieIdpSession(for profileId: UUID) -> IDPSession {
        biometrieIdpSessionForCallsCount += 1
        biometrieIdpSessionForReceivedProfileId = profileId
        biometrieIdpSessionForReceivedInvocations.append(profileId)
        return biometrieIdpSessionForClosure.map { $0(profileId) } ?? biometrieIdpSessionForReturnValue
    }

    // MARK: - userDataStore

    var userDataStoreForCallsCount = 0
    var userDataStoreForCalled: Bool {
        userDataStoreForCallsCount > 0
    }

    var userDataStoreForReceivedProfileId: UUID?
    var userDataStoreForReceivedInvocations: [UUID] = []
    var userDataStoreForReturnValue: SecureUserDataStore!
    var userDataStoreForClosure: ((UUID) -> SecureUserDataStore)?

    func userDataStore(for profileId: UUID) -> SecureUserDataStore {
        userDataStoreForCallsCount += 1
        userDataStoreForReceivedProfileId = profileId
        userDataStoreForReceivedInvocations.append(profileId)
        return userDataStoreForClosure.map { $0(profileId) } ?? userDataStoreForReturnValue
    }

    // MARK: - signatureProvider

    var signatureProviderForCallsCount = 0
    var signatureProviderForCalled: Bool {
        signatureProviderForCallsCount > 0
    }

    var signatureProviderForReceivedProfileId: UUID?
    var signatureProviderForReceivedInvocations: [UUID] = []
    var signatureProviderForReturnValue: NFCSignatureProvider!
    var signatureProviderForClosure: ((UUID) -> NFCSignatureProvider)?

    func signatureProvider(for profileId: UUID) -> NFCSignatureProvider {
        signatureProviderForCallsCount += 1
        signatureProviderForReceivedProfileId = profileId
        signatureProviderForReceivedInvocations.append(profileId)
        return signatureProviderForClosure.map { $0(profileId) } ?? signatureProviderForReturnValue
    }

    // MARK: - idTokenValidator

    var idTokenValidatorForCallsCount = 0
    var idTokenValidatorForCalled: Bool {
        idTokenValidatorForCallsCount > 0
    }

    var idTokenValidatorForReceivedProfileId: UUID?
    var idTokenValidatorForReceivedInvocations: [UUID] = []
    var idTokenValidatorForReturnValue: AnyPublisher<IDTokenValidator, IDTokenValidatorError>!
    var idTokenValidatorForClosure: ((UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError>)?

    func idTokenValidator(for profileId: UUID) -> AnyPublisher<IDTokenValidator, IDTokenValidatorError> {
        idTokenValidatorForCallsCount += 1
        idTokenValidatorForReceivedProfileId = profileId
        idTokenValidatorForReceivedInvocations.append(profileId)
        return idTokenValidatorForClosure.map { $0(profileId) } ?? idTokenValidatorForReturnValue
    }
}
