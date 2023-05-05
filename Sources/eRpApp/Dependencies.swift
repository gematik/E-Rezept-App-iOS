// swiftlint:disable:this file_name
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
import XCTestDynamicOverlay

// MARK: TCA Dependency eRpKit

import eRpKit

extension FHIRDateFormatter: DependencyKey {
    public static let liveValue = FHIRDateFormatter.shared

    public static let testValue = FHIRDateFormatter.shared
}

extension DependencyValues {
    var fhirDateFormatter: FHIRDateFormatter {
        get { self[FHIRDateFormatter.self] }
        set { self[FHIRDateFormatter.self] = newValue }
    }
}

public struct ErxTaskRepositoryDependency: DependencyKey {
    public static let liveValue: ErxTaskRepository? = nil

    public static var previewValue: ErxTaskRepository? = DemoErxTaskRepository(secureUserStore: MemoryStorage())

    public static var testValue: ErxTaskRepository? = UnimplementedErxTaskRepository()
}

extension DependencyValues {
    var erxTaskRepository: ErxTaskRepository {
        get { self[ErxTaskRepositoryDependency.self] ?? changeableUserSessionContainer.userSession.erxTaskRepository }
        set { self[ErxTaskRepositoryDependency.self] = newValue }
    }
}

struct ShipmentInfoDataStoreDependency: DependencyKey {
    static let liveValue: ShipmentInfoDataStore? = nil
    static let previewValue: ShipmentInfoDataStore? = DemoShipmentInfoStore()
    static let testValue: ShipmentInfoDataStore? = nil // to-do
}

extension DependencyValues {
    var shipmentInfoDataStore: ShipmentInfoDataStore {
        get {
            self[ShipmentInfoDataStoreDependency.self] ?? changeableUserSessionContainer.userSession
                .shipmentInfoDataStore
        }
        set { self[ShipmentInfoDataStoreDependency.self] = newValue }
    }
}

// MARK: TCA Dependency eRpLocalStorage

import eRpLocalStorage

struct CoreDataControllerFactoryDependency: DependencyKey {
    static let liveValue: CoreDataControllerFactory = LocalStoreFactory()

    // should be unimplemented
    // static let previewValue: CoreDataControllerFactory =

    static let testValue: CoreDataControllerFactory = UnimplementedCoreDataControllerFactory()
}

extension DependencyValues {
    var coreDataControllerFactory: CoreDataControllerFactory {
        get { self[CoreDataControllerFactoryDependency.self] }
        set { self[CoreDataControllerFactoryDependency.self] = newValue }
    }
}

struct UserDataStoreDependency: DependencyKey {
    static let liveValue: UserDataStore = UserDefaultsStore(userDefaults: .standard)

    static let previewValue: UserDataStore = DummySessionContainer().localUserStore

    static let testValue: UserDataStore = UnimplementedUserDataStore()
}

extension DependencyValues {
    var userDataStore: UserDataStore {
        get { self[UserDataStoreDependency.self] }
        set { self[UserDataStoreDependency.self] = newValue }
    }
}

struct ModelMigratingDependency: DependencyKey {
    static var liveValue: ModelMigrating = {
        let coreDataFactory = CoreDataControllerFactoryDependency.liveValue
        return MigrationManager(
            factory: coreDataFactory,
            erxTaskCoreDataStore: ErxTaskCoreDataStore(
                profileId: nil,
                coreDataControllerFactory: coreDataFactory
            ),
            userDataStore: UserDataStoreDependency.liveValue
        )
    }()

    static let previewValue: ModelMigrating = MigrationManager.failing

    static let testValue: ModelMigrating = UnimplementedModelMigrating()
}

extension DependencyValues {
    var migrationManager: ModelMigrating {
        get { self[ModelMigratingDependency.self] }
        set { self[ModelMigratingDependency.self] = newValue }
    }
}

struct NFCSignatureProviderDependency: DependencyKey {
    static let liveValue: NFCSignatureProvider? = nil

    static let testValue: NFCSignatureProvider? = UnimplementedNFCSignatureProvider()

    static let previewValue: NFCSignatureProvider? = DemoSignatureProvider()
}

extension DependencyValues {
    var nfcSessionProvider: NFCSignatureProvider {
        get { self[NFCSignatureProviderDependency.self] ?? changeableUserSessionContainer.userSession
            .nfcSessionProvider
        }
        set { self[NFCSignatureProviderDependency.self] = newValue }
    }
}

extension ProfileCoreDataStore: DependencyKey {
    public static let liveValue = ProfileCoreDataStore(
        coreDataControllerFactory: CoreDataControllerFactoryDependency.liveValue
    )

    // should be unimplemented
    // public static let previewValue: ProfileCoreDataStore
}

extension DependencyValues {
    var profileCoreDataStore: ProfileCoreDataStore {
        get { self[ProfileCoreDataStore.self] }
        set { self[ProfileCoreDataStore.self] = newValue }
    }
}

struct ProfileDataStoreDependency: DependencyKey {
    static let initialValue: ProfileDataStore = ProfileCoreDataStore.liveValue

    static let liveValue: ProfileDataStore? = nil

    static let previewValue: ProfileDataStore? = DemoProfileDataStore()

    static let testValue: ProfileDataStore? = UnimplementedProfileDataStore()
}

extension DependencyValues {
    var profileDataStore: ProfileDataStore {
        get { self[ProfileDataStoreDependency.self] ?? changeableUserSessionContainer.userSession.profileDataStore }
        set { self[ProfileDataStoreDependency.self] = newValue }
    }
}

// MARK: TCA Dependency IDP

import IDP

struct IDPSessionDependency: DependencyKey {
    static let liveValue: IDPSession? = nil

    static let previewValue: IDPSession? = DemoIDPSession(storage: MemoryStorage())

    static let testValue: IDPSession? = UnimplementedIDPSession()
}

extension DependencyValues {
    var idpSession: IDPSession {
        get { self[IDPSessionDependency.self] ?? changeableUserSessionContainer.userSession.idpSession }
        set { self[IDPSessionDependency.self] = newValue }
    }
}

struct SecureEnclaveSignatureProviderDependency: DependencyKey {
    static let liveValue: SecureEnclaveSignatureProvider = UsersSessionContainerDependency.liveValue.userSession
        .secureEnclaveSignatureProvider

    static let previewValue: SecureEnclaveSignatureProvider = DummySecureEnclaveSignatureProvider()

    static let testValue: SecureEnclaveSignatureProvider = UnimplementedSecureEnclaveSignatureProvider()
}

extension DependencyValues {
    var secureEnclaveSignatureProvider: SecureEnclaveSignatureProvider {
        get { self[SecureEnclaveSignatureProviderDependency.self] }
        set { self[SecureEnclaveSignatureProviderDependency.self] = newValue }
    }
}

struct ExtAuthRequestStorageDependency: DependencyKey {
    static var liveValue: ExtAuthRequestStorage?

    static var previewValue: ExtAuthRequestStorage? = DummyExtAuthRequestStorage()

    static var testValue: ExtAuthRequestStorage? = UnimplementedExtAuthRequestStorage()
}

extension DependencyValues {
    var extAuthRequestStorage: ExtAuthRequestStorage {
        get {
            self[ExtAuthRequestStorageDependency.self] ?? changeableUserSessionContainer.userSession
                .extAuthRequestStorage
        }
        set { self[ExtAuthRequestStorageDependency.self] = newValue }
    }
}

// MARK: TCA Dependency eRpApp

struct DateProviderDependency: DependencyKey {
    static let liveValue: (() -> Date) = {
        Date()
    }
}

extension DependencyValues {
    var dateProvider: () -> Date {
        get { self[DateProviderDependency.self] }
        set { self[DateProviderDependency.self] = newValue }
    }
}

// MARK: Pharmacy

import Pharmacy

struct PharmacyRepositoryDependency: DependencyKey {
    static let liveValue: PharmacyRepository? = nil
    static let previewValue: PharmacyRepository? = nil
}

extension DependencyValues {
    var pharmacyRepository: PharmacyRepository {
        get { self[PharmacyRepositoryDependency.self] ?? changeableUserSessionContainer.userSession.pharmacyRepository }
        set { self[PharmacyRepositoryDependency.self] = newValue }
    }
}

// MARK: ComposableCoreLocation

import ComposableCoreLocation

extension LocationManager: DependencyKey {
    public static var liveValue: LocationManager = .live
    public static var previewValue: LocationManager = .live
    public static var testValue: LocationManager = unimplemented()
}

extension DependencyValues {
    var locationManager: LocationManager {
        get { self[LocationManager.self] }
        set { self[LocationManager.self] = newValue }
    }
}
