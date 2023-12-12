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

import ComposableArchitecture
import Dependencies
import eRpKit
import eRpLocalStorage
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

            mockPharmacyService(scenario, isRecording, dependencies: &dependencies)
        }
    }

    private func mockPharmacyService(_ scenario: Scenario?, _ isRecording: Bool, dependencies: inout DependencyValues) {
        dependencies.pharmacyServiceFactory = PharmacyServiceFactory { fhirClient in
            @Dependency(\.smartMockRegister) var smartMockRegister: SmartMockRegister

            let mock = SmartMockPharmacyRemoteDataStore(
                wrapped: PharmacyFHIRDataSource(fhirClient: fhirClient),
                mocks: scenario?.pharmacyRemoteDataStore,
                isRecording: isRecording
            )

            smartMockRegister.register(mock)
            return mock
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
}

struct Scenario {
    var userDataStore: SmartMockUserDataStore.Mocks?
    var pharmacyRemoteDataStore: SmartMockPharmacyRemoteDataStore.Mocks?
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

        let pharmacyMock: SmartMockPharmacyRemoteDataStore.Mocks? = loadMockData(
            scenarioUrl: scenarioPath,
            with: "PharmacyRemoteDataStore"
        )
        let userDataStoreMock: SmartMockUserDataStore.Mocks? = loadMockData(
            scenarioUrl: scenarioPath,
            with: "UserDataStore"
        )

        return Scenario(userDataStore: userDataStoreMock, pharmacyRemoteDataStore: pharmacyMock)
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
// sourcery:end
