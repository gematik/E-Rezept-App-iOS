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
// swiftlint:disable file_length

import ComposableArchitecture
import Dependencies
import eRpKit
import eRpLocalStorage
import eRpRemoteStorage
import eRpStyleKit
import FHIRClient
import Foundation
import IDP
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
        #if DEBUG
        _ = try? UITestBridgeServer.shared()

        if ProcessInfo.processInfo.environment["UITEST.DISABLE_ANIMATIONS"] != nil {
            mainWindow?.layer.speed = 1000

            // Disable hardware keyboards.
            let setHardwareLayout = NSSelectorFromString("setHardwareLayout:")
            UITextInputMode.activeInputModes
                // Filter `UIKeyboardInputMode`s.
                .filter { $0.responds(to: setHardwareLayout) }
                .forEach { $0.perform(setHardwareLayout, with: nil) }
        }
        @Dependency(\.appSecurityManager) var appSecurityManager: AppSecurityManager

        if ProcessInfo.processInfo.environment["UITEST.RESET"] != nil {
            if let domain = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: domain)
                UserDefaults.standard.synchronize()
            }
            _ = try? FileManager.default.removeItem(at: LocalStoreFactory.defaultDatabaseUrl)

            _ = try? appSecurityManager.save(password: "")
        }
        if let password = ProcessInfo.processInfo.environment["UITEST.SET_APPLICATION_PASSWORD"] {
            _ = try? appSecurityManager.save(password: password)
        }

        if let flagsString = ProcessInfo.processInfo.environment["UITEST.FLAGS"] {
            if let flags = try? JSONDecoder().decode([String].self, from: flagsString.data(using: .utf8) ?? Data()) {
                for flag in flags {
                    UserDefaults.standard.setValue(true, forKey: flag)
                }
                UserDefaults.standard.synchronize()
            }
        }
        #endif
    }
}

#if DEBUG
extension Reducer {
    func setupUITests() -> some Reducer<Self.State, Self.Action> {
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
            // this clashes with erxRemoteDataStoreFactory, as accessing the underlying IDPSession calls the usersession
            // that then prematurely calls the erxRemoteDataStoreFactory from above. The `if`can be removed as soon as
            // we use shared state for the current user
            if scenario?.idpSession != nil {
                dependencies.idpSession = SmartMocks.shared.smartMockIDPSession(scenario, isRecording)
            }
            @Dependency(\.userSession) var userSession

            let loginHandler = UITestLoginHandler()

            dependencies.loginHandlerServiceFactory = LoginHandlerServiceFactory { _, _ in
                loginHandler
            }

            dependencies.avsRedeemService = {
                SmartMocks.shared.smartMockRedeemService(scenario, isRecording, loginHandler)
            }
        }
    }
}

import Combine

struct UITestLoginHandler: LoginHandler {
    @Dependency(\.smartMockState) var smartMockState

    func isAuthenticated() -> AnyPublisher<LoginResult, Never> {
        Just(.success(smartMockState.loginStatus)).eraseToAnyPublisher()
    }

    func isAuthenticatedOrAuthenticate() -> AnyPublisher<LoginResult, Never> {
        Just(.success(smartMockState.loginStatus)).eraseToAnyPublisher()
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

    private var smartMockRedeemService: SmartMockRedeemService?
    mutating func smartMockRedeemService(_ scenario: Scenario?, _ isRecording: Bool,
                                         _ loginHandler: LoginHandler) -> RedeemService {
        if let existingMock = smartMockRedeemService {
            return existingMock
        }
        @Dependency(\.redeemService) var redeemService: RedeemService

        @Dependency(\.userSession) var userSession

        let erxTaskRepositoryRedeemService = ErxTaskRepositoryRedeemService(
            erxTaskRepository: userSession.erxTaskRepository,
            loginHandler: loginHandler
        )

        let mock = SmartMockRedeemService(
            wrapped: erxTaskRepositoryRedeemService,
            mocks: scenario?.redeemService,
            isRecording: isRecording
        )
        smartMockRegister.register(mock)
        smartMockRedeemService = mock
        return mock
    }

    private var smartMockIDPSession: SmartMockIDPSession?
    mutating func smartMockIDPSession(_ scenario: Scenario?, _ isRecording: Bool) -> IDPSession {
        if let existingMock = smartMockIDPSession {
            return existingMock
        }
        @Dependency(\.idpSession) var idpSession: IDPSession
        let mock = SmartMockIDPSession(
            wrapped: idpSession,
            mocks: scenario?.idpSession,
            isRecording: isRecording
        )
        smartMockRegister.register(mock)
        smartMockIDPSession = mock
        return mock
    }
}

struct Scenario {
    var userDataStore: SmartMockUserDataStore.Mocks?
    var pharmacyRemoteDataStore: SmartMockPharmacyRemoteDataStore.Mocks?
    var erxTaskCoreDataStore: SmartMockErxTaskCoreDataStore.Mocks?
    var erxRemoteDataStore: SmartMockErxRemoteDataStore.Mocks?
    var redeemService: SmartMockRedeemService.Mocks?
    var idpSession: SmartMockIDPSession.Mocks?
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
        let redeemService: SmartMockRedeemService.Mocks? = loadMockData(
            scenarioUrl: scenarioPath,
            with: "RedeemService"
        )
        let idpSession: SmartMockIDPSession.Mocks? = loadMockData(
            scenarioUrl: scenarioPath,
            with: "IDPSession"
        )

        return Scenario(
            userDataStore: userDataStoreMock,
            pharmacyRemoteDataStore: pharmacyMock,
            erxTaskCoreDataStore: erxTaskCoreDataStore,
            erxRemoteDataStore: erxRemoteDataStore,
            redeemService: redeemService,
            idpSession: idpSession
        )
    }

    private func loadMockData<T>(scenarioUrl: URL, with name: String) -> T? where T: Codable {
        let filePath = scenarioUrl.appendingPathComponent("\(name).json", isDirectory: false)
        guard FileManager.default.fileExists(atPath: filePath.path),
              let jsonData = try? Data(contentsOf: filePath).applyingDynamicReplacements(scenarioUrl) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(T.self, from: jsonData)
        } catch let DecodingError.typeMismatch(type, context) {
            print(String(data: jsonData, encoding: .utf8))
            print("Type mismatch error: \(type)")
            print("Context: \(context)")
            fatalError("Failed to decode scenario file")
        } catch let error as DecodingError {
            print(String(data: jsonData, encoding: .utf8))
            print("wait")
            switch error {
            case let .valueNotFound(_, context),
                 let .dataCorrupted(context),
                 let .typeMismatch(_, context),
                 let .keyNotFound(_, context):
                fatalError("Failed to decode scenario file '\(name)': \(error.localizedDescription)" +
                    "\n\n\t\(context.codingPath.map(\.stringValue).joined(separator: "."))")
            default:
                fatalError("failed to decode scenario file '\(name)'. Error: \(error.localizedDescription)")
            }
        } catch {
            fatalError("failed to decode scenario file '\(name)'. Error: \(error.localizedDescription)")
        }
    }
}

extension Data {
    // This method loads a JSON file and expands all template variables and file references.
    func applyingDynamicReplacements(_ baseUrl: URL) -> Data {
        // Expand file references
        let expandedFileReferences = expandFileReferences(baseUrl)
        guard let jsonDataAsString = String(data: expandedFileReferences, encoding: .utf8) else {
            fatalError("Something went wrong while converting JSON Data to String")
        }
        guard let result = jsonDataAsString
            // replace placeholders
            .applyingDateReplacements()
            .applyingUUIDReplacements()
            .data(using: .utf8) else {
            fatalError("Something went wrong while converting JSON String back to Data")
        }

        return result
    }
}

// Load the corresponding json file into a json object and return the element the given keypath.
func jsonFile(from filePath: URL, at keyPath: String) -> [String: Any] {
    guard FileManager.default.fileExists(atPath: filePath.path),
          let jsonData = try? Data(contentsOf: filePath) else {
        return [:]
    }

    guard let replacement = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
        fatalError("Could not parse file into JSON object '\(filePath.path)'.")
    }

    let keys = keyPath.split(separator: ".").map { String($0) }
    var result = replacement
    for key in keys {
        guard let dictionary = result[key] as? [String: Any] else {
            fatalError("Could not find key '\(key)' in JSON file.")
        }
        result = dictionary
    }
    return result
}

extension Dictionary where Self.Key == String, Self.Value == Any {
    mutating func expandFileReferences(_ baseUrl: URL) {
        traverse { dictionary in
            dictionary.performFileReplacements(baseUrl)
        }
    }

    mutating func performFileReplacements(_ baseUrl: URL) {
        if let value = self["_FILE"] as? String {
            let values = value.split(separator: "#")
            guard values.count == 2,
                  let filename = values.first,
                  let path = values.last else {
                fatalError("Expected _FILE to have the format: '<filename>#<keypath>'")
            }

            let copy = self
            self = jsonFile(
                from: baseUrl.appendingPathComponent(String(filename), isDirectory: false),
                at: String(path)
            )
            if let value = copy["_REPLACE"] as? [String: String] {
                for (find, replace) in value {
                    traverse { dictionary in
                        for (key, value) in dictionary {
                            if let string = value as? String {
                                dictionary[key] = string.replacingOccurrences(of: find, with: replace)
                            }
                        }
                    }
                }
            }

            for (key, value) in copy {
                if key == "_FILE" || key == "_REPLACE" {
                    continue
                }
                self[key] = value
            }
        }
    }

    mutating func traverse(_ alterDictionary: (inout [String: Any]) -> Void) {
        for (key, value) in self {
            if let dictionary = value as? [String: Any] {
                var dictionary = dictionary
                dictionary.traverse(alterDictionary)
                self[key] = dictionary
            } else if var array = value as? [Any] {
                array.traverse(alterDictionary)
                self[key] = array
            }
        }
        alterDictionary(&self)
    }
}

extension Array where Element == Any {
    mutating func traverse(_ alterDictionary: (inout [String: Any]) -> Void) {
        for index in 0 ..< count {
            if let dictionary = self[index] as? [String: Any] {
                var dictionary = dictionary
                dictionary.traverse(alterDictionary)
                self[index] = dictionary
            } else if var array = self[index] as? [Any] {
                array.traverse(alterDictionary)
                self[index] = array
            }
        }
    }
}

extension Data {
    // This extension method expands file references in the JSON data. It replaces all objects with occurrences of the
    // `_FILE` key with the corresponding file content. The value of the `_FILE` key must be a string with the format
    // `<filename>#<keypath>`. The `<filename>` is the name of the file to load and the `<keypath>` is the path to the
    // object within the JSON file. The method returns the expanded JSON data.
    // Another key named `_REPLACE` can be used to replace placeholders in the JSON file. The value of the `_REPLACE`
    // key is a dictionary with the format `<find>: <replace>`. The method replaces all occurrences of `<find>` with
    // `<replace>` in the JSON file.
    func expandFileReferences(_ baseUrl: URL) -> Data {
        guard var json = try? JSONSerialization.jsonObject(with: self, options: []) else {
            return self
        }

        if var json2 = json as? [String: Any] {
            json2.expandFileReferences(baseUrl)
            json = json2
        }
        if var json2 = json as? [String: Any] {
            json2.traverse { dictionary in
                dictionary.expandFileReferences(baseUrl)
            }
            json = json2
        }

        guard let data = try? JSONSerialization.data(withJSONObject: json as Any, options: []) else {
            return self
        }

        return data
    }
}

extension String {
    // This extension method applies UUID replacements to the string using a specific pattern. The pattern is defined as
    // "{{UUID}}". It replaces each occurrenc of the pattern with a new UUID string.
    func applyingUUIDReplacements() -> String {
        let pattern = #"\{\{UUID\}\}"#

        // Create a regular expression using the pattern.
        let uuidRegex: NSRegularExpression
        do {
            uuidRegex = try NSRegularExpression(pattern: pattern)
        } catch {
            fatalError(error.localizedDescription)
        }

        var result = self

        // Find all matches of the UUID pattern in the string.
        let matches = uuidRegex.matches(in: self, options: [], range: NSRange(location: 0, length: count))

        // Iterate through the matches in reverse order to ensure correct ranges.
        for match in matches.reversed() {
            guard let range = Range(match.range, in: result) else { continue }
            result.replaceSubrange(range, with: UUID().uuidString)
        }

        // Return the final result with applied UUID replacements.
        return result
    }

    // This extension method applies date replacements to the string using a specific pattern.
    // The pattern is defined as "{{<type>:<offset>#<format>}".
    // - The "<type>" specifies the type of date replacement. The following types are supported:
    //   - DATE: Replaces the placeholder with the current date resulting in the format `yyyy-MM-dd`.
    //   - TIME: Replaces the placeholder with the current time resulting in the format `HH:mm:ss`.
    //   - DATETIME: Replaces the placeholder with the current date and time resulting in the format
    //     `yyyy-MM-dd'T'HH:mm:ss.SSSxxxxx`
    // - The "<offset>" specifies the offset value and unit for the date replacement. Use positive or negative integers
    //   in combination with a unit (Y = years, M = months, D = days, h = hours, m = minutes, s = seconds) to specify
    //   the offset. If no offset is specified, the current date and time will be used.
    // - The "<format>" specifies the format of the resulting date string.
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func applyingDateReplacements() -> String {
        let pattern = #"\{\{(?<type>DATE|TIME|DATETIME)(:(?<offset>[+-]\d+)(?<unit>[YMDhms])?)?(#(?<format>.+))?\}\}"#

        // Create a regular expression using the pattern.
        let dateRegex: NSRegularExpression
        do {
            dateRegex = try NSRegularExpression(pattern: pattern)
        } catch {
            fatalError(error.localizedDescription)
        }

        var result = self

        // Find all matches of the date pattern in the string.
        let matches = dateRegex.matches(in: self, options: [], range: NSRange(location: 0, length: count))

        // Iterate through the matches in reverse order to ensure correct ranges.
        for match in matches.reversed() {
            let matchString = (self as NSString).substring(with: match.range)
            guard let matchResult = dateRegex.firstMatch(
                in: matchString,
                options: [],
                range: NSRange(location: 0, length: matchString.count)
            ) else { continue }

            let type: String
            let typeRange = matchResult.range(withName: "type")
            if typeRange.location != NSNotFound,
               let range = Range(typeRange, in: matchString) {
                type = String(matchString[range])
            } else {
                type = "DATE"
            }

            // Extract the offset value from the match, if present.
            let offset: Int
            let offsetRange = matchResult.range(withName: "offset")
            if offsetRange.location != NSNotFound,
               let range = Range(offsetRange, in: matchString) {
                offset = Int(matchString[range]) ?? 0
            } else {
                offset = 0
            }

            // Extract the offset unit from the match, if present.
            let unit: Calendar.Component
            let unitRange = matchResult.range(withName: "unit")
            if unitRange.location != NSNotFound,
               let range = Range(unitRange, in: matchString) {
                switch matchString[range] {
                case "Y":
                    unit = .year
                case "M":
                    unit = .month
                case "D":
                    unit = .day
                case "h":
                    unit = .hour
                case "m":
                    unit = .minute
                case "s":
                    unit = .second
                default:
                    unit = .day
                }
            } else {
                unit = .day
            }

            // Extract the format from the match, if present.
            let format: String
            let formatRange = matchResult.range(withName: "format")
            if formatRange.location != NSNotFound,
               let range = Range(formatRange, in: matchString) {
                format = String(matchString[range])
            } else {
                format = getDefaultFormat(for: type)
            }

            // Calculate the resulting date by adding the offset to the current date.
            guard let date = Calendar.current.date(byAdding: unit, value: offset, to: Date()) else { continue }

            // Format the date using the specified format.
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            let dateString = dateFormatter.string(from: date)

            // Replace the match string with the formatted date in the result.
            result = result.replacingOccurrences(of: matchString, with: dateString)
        }

        // Return the final result with applied date replacements.
        return result
    }

    private func getDefaultFormat(for type: String) -> String {
        switch type {
        case "DATE":
            return "yyyy-MM-dd"
        case "TIME":
            return "HH:mm:ss"
        case "DATETIME":
            return "yyyy-MM-dd'T'HH:mm:ss.SSSxxxxx"
        default:
            return "yyyy-MM-dd"
        }
    }
}

// sourcery:begin: SmartMock
extension UserDataStore {}
extension PharmacyRemoteDataStore {}
extension ErxTaskCoreDataStore {}
extension ErxRemoteDataStore {}
extension RedeemService {}
extension IDPSession {}
// sourcery:end

#endif
