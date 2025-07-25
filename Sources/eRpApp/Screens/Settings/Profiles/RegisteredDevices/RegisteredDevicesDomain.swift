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

import CasePaths
import Combine
import ComposableArchitecture
import eRpKit
import Foundation
import IDP

@Reducer
struct RegisteredDevicesDomain {
    @ObservableState
    struct State: Equatable {
        let profileId: UUID

        @Presents var destination: Destination.State?

        var thisDeviceKeyIdentifier: String?

        var content: Content = .notLoaded

        @CasePathable
        enum Content: Equatable {
            case loaded([Entry])
            case loading([Entry])
            case notLoaded
        }

        struct Entry: Identifiable, Equatable {
            let id: Int
            let name: String
            let date: String

            let keyIdentifier: String?

            init(_ pairingEntry: PairingEntry, dateFormatter: DateFormatter = DateFormatter()) {
                if let signedPairingData = try? SignedPairingData(from: pairingEntry.signedPairingData) {
                    keyIdentifier = signedPairingData.originalPairingData.keyIdentifier
                } else {
                    keyIdentifier = nil
                }
                name = pairingEntry.name
                date = dateFormatter.string(from: pairingEntry.creationTime)

                var hasher = Hasher()
                name.hash(into: &hasher)
                date.hash(into: &hasher)
                id = hasher.finalize()
            }
        }
    }

    @Reducer(state: .equatable, action: .equatable)
    enum Destination {
        // sourcery: AnalyticsScreen = cardWall
        case cardWallCAN(CardWallCANDomain)
        // sourcery: AnalyticsScreen = alert
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)

        enum Alert: Equatable {
            case dismiss
        }
    }

    enum Action: Equatable {
        case task
        case loadDevices
        case deleteDevice(String)

        case showCardWall(CardWallCANDomain.State)

        case destination(PresentationAction<Destination.Action>)

        case response(Response)

        enum Response: Equatable {
            case taskReceived(Result<PairingEntries, RegisteredDevicesServiceError>)
            case loadDevicesReceived(Result<PairingEntries, RegisteredDevicesServiceError>)
            case deleteDeviceReceived(Result<Bool, RegisteredDevicesServiceError>)
            case deviceIdReceived(String?)
        }
    }

    // sourcery: CodedError = "017"
    enum Error: Swift.Error, Equatable {
        // sourcery: errorCode = "01"
        case generic(String)
    }

    @Dependency(\.schedulers) var schedulers: Schedulers
    @Dependency(\.registeredDevicesService) var registeredDevicesService: RegisteredDevicesService
    @Dependency(\.uiDateFormatter.compactDateAndTimeFormatter) var dateFormatter: DateFormatter

    var body: some Reducer<State, Action> {
        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            let currentState = state.content[case: \State.Content.Cases.loaded] ?? []
            state.content = .loading(currentState)
            return .merge(
                getRegisteredDevicesWithSurpressedError(profileId: state.profileId),
                getDeviceId(for: state.profileId)
            )
        case let .response(.taskReceived(result)):
            switch result {
            case let .success(entries):
                state.content = .loaded(
                    entries.pairingEntries
                        .sorted(by: { $0.creationTime > $1.creationTime })
                        .map { ($0, dateFormatter) }
                        .map(State.Entry.init)
                )
            case .failure:
                state.content = .notLoaded
            }
            return .none

        case .loadDevices:
            let currentState = state.content[case: \State.Content.Cases.loaded] ?? []
            state.content = .loading(currentState)
            return .merge(
                getRegisteredDevices(profileId: state.profileId),
                getDeviceId(for: state.profileId)
            )
        case let .response(.loadDevicesReceived(.success(entries))):
            state.content = .loaded(
                entries.pairingEntries
                    .sorted(by: { $0.creationTime > $1.creationTime })
                    .map { ($0, dateFormatter) }
                    .map(State.Entry.init)
            )
            return .none
        case let .response(.loadDevicesReceived(.failure(error))):
            state.content = .notLoaded
            state.destination = .alert(.init(for: error))
            return .none
        case let .response(.deviceIdReceived(keyIdentifier)):
            state.thisDeviceKeyIdentifier = keyIdentifier
            return .none
        case let .showCardWall(cardWallState):
            state.content = .notLoaded
            state.destination = .cardWallCAN(cardWallState)
            return .none
        case .destination(.presented(.cardWallCAN(action: .delegate(.close)))):
            state.destination = nil
            return .send(.task)
        case let .deleteDevice(device):
            return .publisher(
                deleteDevice(device, of: state.profileId)
                    .eraseToAnyPublisher
            )
        case let .response(.deleteDeviceReceived(.failure(error))):
            state.destination = .alert(.init(for: error))
            return .none
        case .response(.deleteDeviceReceived(.success)):
            return getRegisteredDevices(profileId: state.profileId)
        case .destination:
            return .none
        }
    }
}

extension RegisteredDevicesDomain {
    func getRegisteredDevicesWithSurpressedError(profileId: UUID) -> Effect<RegisteredDevicesDomain.Action> {
        .publisher(
            registeredDevicesService.registeredDevices(for: profileId)
                .map { RegisteredDevicesDomain.Action.response(.taskReceived(.success($0))) }
                .catch { error -> AnyPublisher<RegisteredDevicesDomain.Action, Never> in
                    Just(RegisteredDevicesDomain.Action.response(.taskReceived(.failure(error))))
                        .eraseToAnyPublisher()
                }
                .receive(on: schedulers.main)
                .eraseToAnyPublisher
        )
    }

    func getRegisteredDevices(profileId: UUID) -> Effect<RegisteredDevicesDomain.Action> {
        .publisher(
            registeredDevicesService.registeredDevices(for: profileId)
                .map { RegisteredDevicesDomain.Action.response(.loadDevicesReceived(.success($0))) }
                .catch { error -> AnyPublisher<RegisteredDevicesDomain.Action, Never> in
                    if RegisteredDevicesServiceError.missingAuthentication == error {
                        return registeredDevicesService.cardWall(for: profileId)
                            .map(RegisteredDevicesDomain.Action.showCardWall)
                            .eraseToAnyPublisher()
                    }
                    return Just(RegisteredDevicesDomain.Action.response(.loadDevicesReceived(.failure(error))))
                        .eraseToAnyPublisher()
                }
                .receive(on: schedulers.main)
                .eraseToAnyPublisher
        )
    }

    func getDeviceId(for profileId: UUID) -> Effect<RegisteredDevicesDomain.Action> {
        .publisher(
            registeredDevicesService.deviceId(for: profileId)
                .map(RegisteredDevicesDomain.Action.Response.deviceIdReceived)
                .map(RegisteredDevicesDomain.Action.response)
                .receive(on: schedulers.main)
                .eraseToAnyPublisher
        )
    }

    func deleteDevice(_ deviceId: String, of profileId: UUID) -> AnyPublisher<RegisteredDevicesDomain.Action, Never> {
        registeredDevicesService.deleteDevice(deviceId, of: profileId)
            .catchToPublisher()
            .map(RegisteredDevicesDomain.Action.Response.deleteDeviceReceived)
            .map(RegisteredDevicesDomain.Action.response)
            .receive(on: schedulers.main)
            .eraseToAnyPublisher()
    }
}

extension RegisteredDevicesDomain {
    enum Dummies {
        static let state = State(profileId: UUID())
        static let loadingState = State(
            profileId: UUID(),
            destination: nil,
            content: .loading([])
        )
        static let devicesState = State(
            profileId: UUID(),
            destination: nil,
            thisDeviceKeyIdentifier: "a98765432",
            content: .loaded([
                State.Entry(PairingEntry.Dummies.deviceA),
                State.Entry(PairingEntry.Dummies.deviceB),
            ])
        )
        static let loadedNoDevices = State(
            profileId: UUID(),
            destination: nil,
            thisDeviceKeyIdentifier: nil,
            content: .loaded([])
        )
        static let loadingWithDevicesState = State(
            profileId: UUID(),
            destination: nil,
            content: .loading([
                State.Entry(PairingEntry.Dummies.deviceA),
                State.Entry(PairingEntry.Dummies.deviceB),
            ])
        )
        static let cardWallState = State(
            profileId: UUID(),
            destination: .cardWallCAN(.init(isDemoModus: false, profileId: UUID(), can: ""))
        )

        static let store = store(for: state)

        static func store(
            for state: State
        ) -> StoreOf<RegisteredDevicesDomain> {
            Store(
                initialState: state
            ) {
                EmptyReducer()
            }
        }
    }
}

extension PairingEntry {
    enum Dummies {
        static let deviceA = PairingEntry(
            name: "iPhone X",
            signedPairingData: SignedPairingData.Dummies.signedPairingDataA.serialize(),
            creationTime: Date()
        )
        static let deviceB = PairingEntry(
            name: "iPhone SE",
            signedPairingData: SignedPairingData.Dummies.signedPairingDataB.serialize(),
            creationTime: .distantPast
        )
    }
}

extension PairingData {
    enum Dummies {
        static let pairingDataA = PairingData(
            authCertSubjectPublicKeyInfo: "",
            notAfter: Int(Date().timeIntervalSinceReferenceDate),
            product: "Device A",
            serialnumber: "123456",
            keyIdentifier: "a98765432",
            seSubjectPublicKeyInfo: "asdfghj",
            issuer: "Gematik KK"
        )
        static let pairingDataB = PairingData(
            authCertSubjectPublicKeyInfo: "",
            notAfter: Int(Date().timeIntervalSinceReferenceDate),
            product: "Device B",
            serialnumber: "123456",
            keyIdentifier: "b98765432",
            seSubjectPublicKeyInfo: "asdfghj",
            issuer: "Gematik KK"
        )
    }
}

extension SignedPairingData {
    enum Dummies {
        static let signedPairingDataA = SignedPairingData(
            originalPairingData: PairingData.Dummies.pairingDataA,
            signedPairingData: {
                let pairingDataHeader = JWT.Header(alg: JWT.Algorithm.bp256r1, typ: "JWT")
                // swiftlint:disable:next force_try
                return try! JWT(header: pairingDataHeader, payload: PairingData.Dummies.pairingDataA)
            }()
        )
        static let signedPairingDataB = SignedPairingData(
            originalPairingData: PairingData.Dummies.pairingDataB,
            signedPairingData: {
                let pairingDataHeader = JWT.Header(alg: JWT.Algorithm.bp256r1, typ: "JWT")
                // swiftlint:disable:next force_try
                return try! JWT(header: pairingDataHeader, payload: PairingData.Dummies.pairingDataB)
            }()
        )
    }
}
