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

// MARK: - MockProfileSecureDataWiper -

final class MockProfileSecureDataWiper: ProfileSecureDataWiper {
    // MARK: - wipeSecureData

    var wipeSecureDataOfCallsCount = 0
    var wipeSecureDataOfCalled: Bool {
        wipeSecureDataOfCallsCount > 0
    }

    var wipeSecureDataOfReceivedProfileId: UUID?
    var wipeSecureDataOfReceivedInvocations: [UUID] = []
    var wipeSecureDataOfReturnValue: AnyPublisher<Void, Never>!
    var wipeSecureDataOfClosure: ((UUID) -> AnyPublisher<Void, Never>)?

    func wipeSecureData(of profileId: UUID) -> AnyPublisher<Void, Never> {
        wipeSecureDataOfCallsCount += 1
        wipeSecureDataOfReceivedProfileId = profileId
        wipeSecureDataOfReceivedInvocations.append(profileId)
        return wipeSecureDataOfClosure.map { $0(profileId) } ?? wipeSecureDataOfReturnValue
    }

    // MARK: - logout

    var logoutProfileCallsCount = 0
    var logoutProfileCalled: Bool {
        logoutProfileCallsCount > 0
    }

    var logoutProfileReceivedProfile: Profile?
    var logoutProfileReceivedInvocations: [Profile] = []
    var logoutProfileReturnValue: AnyPublisher<Void, Never>!
    var logoutProfileClosure: ((Profile) -> AnyPublisher<Void, Never>)?

    func logout(profile: Profile) -> AnyPublisher<Void, Never> {
        logoutProfileCallsCount += 1
        logoutProfileReceivedProfile = profile
        logoutProfileReceivedInvocations.append(profile)
        return logoutProfileClosure.map { $0(profile) } ?? logoutProfileReturnValue
    }

    // MARK: - secureStorage

    var secureStorageCallsCount = 0
    var secureStorageCalled: Bool {
        secureStorageCallsCount > 0
    }

    var secureStorageReceivedProfileId: UUID?
    var secureStorageReceivedInvocations: [UUID] = []
    var secureStorageReturnValue: SecureUserDataStore!
    var secureStorageClosure: ((UUID) -> SecureUserDataStore)?

    func secureStorage(of profileId: UUID) -> SecureUserDataStore {
        secureStorageCallsCount += 1
        secureStorageReceivedProfileId = profileId
        secureStorageReceivedInvocations.append(profileId)
        return secureStorageClosure.map { $0(profileId) } ?? secureStorageReturnValue
    }
}
