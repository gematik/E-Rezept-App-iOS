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
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import eRpStyleKit
import FHIRClient
import Foundation
import Pharmacy
import SwiftUI

extension View {
    func setupUITests() -> some View {
        #if DEBUG
        disableTooltips()
        #else
        return self
        #endif
    }
}

extension View {
    func disableTooltips() -> some View {
        environment(
            \.tooltipDisplayStorage,
            TooltipDisplayStorage(
                tooltipHidden: { _ in
                    true
                }, setTooltipHidden: { _, _ in
                }
            )
        )
    }
}

extension SceneDelegate {
    func setupUITests() {
        if ProcessInfo.processInfo.environment["UITEST.DISABLE_ANIMATIONS"] != nil {
            mainWindow?.layer.speed = 100
        }

        if ProcessInfo.processInfo.environment["UITEST.RESET"] != nil {
            if let domain = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: domain)
                UserDefaults.standard.synchronize()
            }
            _ = try? FileManager.default.removeItem(at: LocalStoreFactory.defaultDatabaseUrl)
        }
    }
}

extension ReducerProtocol {
    func setupUITests() -> some ReducerProtocol<Self.State, Self.Action> {
        let isRecording = ProcessInfo.processInfo.environment["UITEST.RECORD_MOCKS"] != nil
        let scenario: Scenario?

        if !isRecording,
           let scenarioName = ProcessInfo.processInfo.environment["UITEST.SCENARIO_NAME"] {
            scenario = ScenarioLoader().load(scenario: scenarioName)
        } else {
            scenario = nil
        }

        // swiftformat:disable:next redundantSelf
        return self.transformDependency(\.self) { dependencies in
            guard scenario != nil || isRecording else { return }

            dependencies.userDataStore = SmartMocks.shared.smartMockUserDataStore(scenario, isRecording)
            dependencies.pharmacyServiceFactory = PharmacyServiceFactory { fhirClient in
                SmartMocks.shared.smartMockPharmacyService(fhirClient: fhirClient, scenario, isRecording)
            }
            dependencies.erxTaskCoreDataStoreFactory = ErxTaskCoreDataStoreFactory { uuid, coreDataControllerFactory in
                SmartMocks.shared.smartMockErxTaskCoreDataStore(
                    uuid: uuid,
                    coreDataControllerFactory: coreDataControllerFactory,
                    scenario,
                    isRecording
                )
            }
            dependencies.erxRemoteDataStoreFactory = ErxRemoteDataStoreFactory { fhirClient in
                SmartMocks.shared.smartMockErxRemoteDataStore(fhirClient: fhirClient, scenario, isRecording)
            }
        }
    }
}

// Keep static instances of SmartMocks to avoid multiple creations while reducers are called multiple times
struct SmartMocks {
    @Dependency(\.smartMockRegister) var smartMockRegister: SmartMockRegister
    static var shared = SmartMocks()

    private var smartMockUserDataStore: SmartMockUserDataStore?
    mutating func smartMockUserDataStore(_ scenario: Scenario?, _ isRecording: Bool) -> UserDataStore {
        if let existingMock = smartMockUserDataStore {
            return existingMock
        }
        @Dependency(\.userDataStore) var userDataStore: UserDataStore

        let mock = SmartMockUserDataStore(
            wrapped: userDataStore,
            mocks: scenario?.userDataStore,
            isRecording: isRecording
        )
        smartMockRegister.register(mock)
        smartMockUserDataStore = mock
        return mock
    }

    private var smartMockPharmacyService: SmartMockPharmacyRemoteDataStore?
    mutating func smartMockPharmacyService(fhirClient: FHIRClient, _ scenario: Scenario?,
                                           _ isRecording: Bool) -> PharmacyRemoteDataStore {
        if let existingMock = smartMockPharmacyService {
            return existingMock
        }
        let pharmacyFhirDataSource = PharmacyFHIRDataSource(fhirClient: fhirClient)

        let mock = SmartMockPharmacyRemoteDataStore(
            wrapped: pharmacyFhirDataSource,
            mocks: scenario?.pharmacyRemoteDataStore,
            isRecording: isRecording
        )
        smartMockRegister.register(mock)
        smartMockPharmacyService = mock
        return mock
    }

    private var smartMockErxTaskCoreDataStore: SmartMockErxTaskCoreDataStore?
    mutating func smartMockErxTaskCoreDataStore(
        uuid: UUID?,
        coreDataControllerFactory: CoreDataControllerFactory,
        _ scenario: Scenario?,
        _ isRecording: Bool
    ) -> ErxTaskCoreDataStore {
        if let existingMock = smartMockErxTaskCoreDataStore {
            return existingMock
        }
        let erxTaskCoreDataStore = DefaultErxTaskCoreDataStore(
            profileId: uuid,
            coreDataControllerFactory: coreDataControllerFactory
        )

        let mock = SmartMockErxTaskCoreDataStore(
            wrapped: erxTaskCoreDataStore,
            mocks: scenario?.erxTaskCoreDataStore,
            isRecording: isRecording
        )
        smartMockRegister.register(mock)
        smartMockErxTaskCoreDataStore = mock
        return mock
    }

    private var smartMockErxRemoteDataStore: SmartMockErxRemoteDataStore?
    mutating func smartMockErxRemoteDataStore(
        fhirClient: FHIRClient,
        _ scenario: Scenario?,
        _ isRecording: Bool
    ) -> ErxRemoteDataStore {
        if let existingMock = smartMockErxRemoteDataStore {
            return existingMock
        }
        let erxTaskFHIRDataStore = ErxTaskFHIRDataStore(fhirClient: fhirClient)

        let mock = SmartMockErxRemoteDataStore(
            wrapped: erxTaskFHIRDataStore,
            mocks: scenario?.erxRemoteDataStore,
            isRecording: isRecording
        )
        smartMockRegister.register(mock)
        smartMockErxRemoteDataStore = mock
        return mock
    }
}

struct Scenario {
    var userDataStore: SmartMockUserDataStore.Mocks?
    var pharmacyRemoteDataStore: SmartMockPharmacyRemoteDataStore.Mocks?
    var erxTaskCoreDataStore: SmartMockErxTaskCoreDataStore.Mocks?
    var erxRemoteDataStore: SmartMockErxRemoteDataStore.Mocks?
}

struct ScenarioLoader {
    func load(scenario: String) -> Scenario? {
        let fileManager = FileManager.default

        guard let bundlePath = Bundle.main.url(forResource: "TestScenarios", withExtension: "bundle") else {
            return nil
        }

        let scenarioPath = bundlePath.appendingPathComponent(scenario, isDirectory: true)
        var isDirectory: ObjCBool = true
        guard !fileManager.fileExists(atPath: scenarioPath.absoluteString, isDirectory: &isDirectory),
              isDirectory.boolValue == true else {
            return nil
        }

        let userDataStoreMock: SmartMockUserDataStore.Mocks? = loadMockData(
            scenarioUrl: scenarioPath,
            with: "UserDataStore"
        )
        let pharmacyMock: SmartMockPharmacyRemoteDataStore.Mocks? = loadMockData(
            scenarioUrl: scenarioPath,
            with: "PharmacyRemoteDataStore"
        )
        let erxTaskCoreDataStore: SmartMockErxTaskCoreDataStore.Mocks? = loadMockData(
            scenarioUrl: scenarioPath,
            with: "ErxTaskCoreDataStore"
        )
        let erxRemoteDataStore: SmartMockErxRemoteDataStore.Mocks? = loadMockData(
            scenarioUrl: scenarioPath,
            with: "ErxRemoteDataStore"
        )

        return Scenario(
            userDataStore: userDataStoreMock,
            pharmacyRemoteDataStore: pharmacyMock,
            erxTaskCoreDataStore: erxTaskCoreDataStore,
            erxRemoteDataStore: erxRemoteDataStore
        )
    }

    private func loadMockData<T>(scenarioUrl: URL, with name: String) -> T? where T: Codable {
        let filePath = scenarioUrl.appendingPathComponent("\(name).json", isDirectory: false)
        guard let jsonData = try? Data(contentsOf: filePath) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: jsonData)
    }
}

// sourcery:begin: SmartMock
extension UserDataStore {}
extension PharmacyRemoteDataStore {}
extension ErxTaskCoreDataStore {}
extension ErxRemoteDataStore {}
// sourcery:end
