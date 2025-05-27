// swiftlint:disable:this file_name
//
//  Copyright (c) 2024 gematik GmbH
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

import ComposableArchitecture
import Dependencies
import Foundation
import XCTestDynamicOverlay

// MARK: TCA Dependency eRpKit

import eRpKit

extension FHIRDateFormatter: @retroactive
DependencyKey {
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

    public static var previewValue: ErxTaskRepository? = DummyErxTaskRepository()

    public static var testValue: ErxTaskRepository? = UnimplementedErxTaskRepository()
}

extension DependencyValues {
    var erxTaskRepository: ErxTaskRepository {
        get { self[ErxTaskRepositoryDependency.self] ?? changeableUserSessionContainer.userSession.erxTaskRepository }
        set { self[ErxTaskRepositoryDependency.self] = newValue }
    }
}

// `Unimplemented` code generation already done by `public struct ErxTaskRepositoryDependency: DependencyKey`
// sourcery: skipUnimplemented
public struct EntireErxTaskRepositoryDependency: DependencyKey {
    public static let liveValue: ErxTaskRepository? = nil

    public static var previewValue: ErxTaskRepository? = DummyErxTaskRepository()

    public static var testValue: ErxTaskRepository? = UnimplementedErxTaskRepository()
}

extension DependencyValues {
    var entireErxTaskRepository: ErxTaskRepository {
        get {
            self[EntireErxTaskRepositoryDependency.self] ?? changeableUserSessionContainer.userSession
                .entireErxTaskRepository
        }
        set { self[EntireErxTaskRepositoryDependency.self] = newValue }
    }
}

struct OrdersRepositoryDependency: DependencyKey {
    static let liveValue: OrdersRepository? = nil

    static var previewValue: OrdersRepository? = DummyOrdersRepository()

    static var testValue: OrdersRepository? = UnimplementedOrdersRepository()
}

extension DependencyValues {
    var ordersRepository: OrdersRepository {
        get { self[OrdersRepositoryDependency.self] ?? changeableUserSessionContainer.userSession.ordersRepository }
        set { self[OrdersRepositoryDependency.self] = newValue }
    }
}

struct InternalCommunicationProtocolDependency: DependencyKey {
    static let liveValue: InternalCommunicationProtocol = {
        @Dependency(\.userDataStore) var userDataStore
        @Dependency(\.internalCommunicationsRepository) var internalCommunicationsRepository
        return DefaultInternalCommunication(userDataStore: userDataStore,
                                            internalCommunicationsRepository: internalCommunicationsRepository)
    }()

    static var previewValue: InternalCommunicationProtocol = DummyInternalCommunicationProtocol()

    static var testValue: InternalCommunicationProtocol = UnimplementedInternalCommunicationProtocol()
}

extension DependencyValues {
    var internalCommunicationProtocol: InternalCommunicationProtocol {
        get { self[InternalCommunicationProtocolDependency.self] }
        set { self[InternalCommunicationProtocolDependency.self] = newValue }
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

struct MedicationScheduleStoreDependency: DependencyKey {
    static let liveValue: MedicationScheduleStore = {
        @Dependency(\.coreDataControllerFactory) var coreDataControllerFactory
        return MedicationScheduleCoreDataStore(coreDataControllerFactory: coreDataControllerFactory)
    }()

    static let previewValue: MedicationScheduleStore = UnimplementedMedicationScheduleStore()

    static let testValue: MedicationScheduleStore = UnimplementedMedicationScheduleStore()
}

extension DependencyValues {
    var medicationScheduleStore: MedicationScheduleStore {
        get { self[MedicationScheduleStoreDependency.self] }
        set { self[MedicationScheduleStoreDependency.self] = newValue }
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
            erxTaskCoreDataStore: DefaultErxTaskCoreDataStore(
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

extension ProfileCoreDataStore: @retroactive
DependencyKey {
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

import LocalAuthentication

struct SecurityPolicyEvaluatorDependency: DependencyKey {
    static let liveValue: SecurityPolicyEvaluator = LAContext()

    static var testValue: SecurityPolicyEvaluator = UnimplementedSecurityPolicyEvaluator()
}

extension DependencyValues {
    var securityPolicyEvaluator: SecurityPolicyEvaluator {
        get { self[SecurityPolicyEvaluatorDependency.self] }
        set { self[SecurityPolicyEvaluatorDependency.self] = newValue }
    }
}

// MARK: Pharmacy

import Pharmacy

struct PharmacyRepositoryDependency: DependencyKey {
    static let liveValue: PharmacyRepository? = nil
    static let previewValue: PharmacyRepository? = nil
    static let testValue: PharmacyRepository? = UnimplementedPharmacyRepository()
}

extension DependencyValues {
    var pharmacyRepository: PharmacyRepository {
        get { self[PharmacyRepositoryDependency.self] ?? changeableUserSessionContainer.userSession.pharmacyRepository }
        set { self[PharmacyRepositoryDependency.self] = newValue }
    }
}

// MARK: factories

import FHIRClient
import FHIRVZD

struct PharmacyServiceFactory {
    let construct: (_ fhirClient: FHIRClient, _ fhirVZDSession: FHIRVZDSession) -> PharmacyRemoteDataStore

    init(construct: @escaping (_ fhirClient: FHIRClient, _ fhirVZDSession: FHIRVZDSession) -> PharmacyRemoteDataStore) {
        self.construct = construct
    }
}

extension PharmacyServiceFactory: DependencyKey {
    static var liveValue = PharmacyServiceFactory { fhirClient, fhirVZDSession in
        HealthcareServiceFHIRDataSource(fhirClient: fhirClient, session: fhirVZDSession)
    }
}

extension DependencyValues {
    var pharmacyServiceFactory: PharmacyServiceFactory {
        get { self[PharmacyServiceFactory.self] }
        set { self[PharmacyServiceFactory.self] = newValue }
    }
}

struct LoginHandlerServiceFactory {
    let construct: (_ idpSession: IDPSession, _ signatureProvider: SecureEnclaveSignatureProvider) -> LoginHandler

    init(construct: @escaping (_ idpSession: IDPSession, _ signatureProvider: SecureEnclaveSignatureProvider)
        -> LoginHandler) {
        self.construct = construct
    }
}

extension LoginHandlerServiceFactory: DependencyKey {
    static var liveValue = LoginHandlerServiceFactory(construct: DefaultLoginHandler.init)
}

extension DependencyValues {
    var loginHandlerServiceFactory: LoginHandlerServiceFactory {
        get { self[LoginHandlerServiceFactory.self] }
        set { self[LoginHandlerServiceFactory.self] = newValue }
    }
}

struct ErxTaskCoreDataStoreFactory {
    let construct: (UUID?, CoreDataControllerFactory) -> ErxTaskCoreDataStore

    init(construct: @escaping (UUID?, CoreDataControllerFactory) -> ErxTaskCoreDataStore) {
        self.construct = construct
    }
}

extension ErxTaskCoreDataStoreFactory: DependencyKey {
    static var liveValue = ErxTaskCoreDataStoreFactory(construct: DefaultErxTaskCoreDataStore.init)
}

extension DependencyValues {
    var erxTaskCoreDataStoreFactory: ErxTaskCoreDataStoreFactory {
        get { self[ErxTaskCoreDataStoreFactory.self] }
        set { self[ErxTaskCoreDataStoreFactory.self] = newValue }
    }
}

import eRpRemoteStorage

struct ErxRemoteDataStoreFactory {
    let construct: (FHIRClient) -> ErxRemoteDataStore

    init(construct: @escaping (FHIRClient) -> ErxRemoteDataStore) {
        self.construct = construct
    }
}

extension ErxRemoteDataStoreFactory: DependencyKey {
    static var liveValue = ErxRemoteDataStoreFactory(construct: ErxTaskFHIRDataStore.init)
}

extension DependencyValues {
    var erxRemoteDataStoreFactory: ErxRemoteDataStoreFactory {
        get { self[ErxRemoteDataStoreFactory.self] }
        set { self[ErxRemoteDataStoreFactory.self] = newValue }
    }
}
