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

import CasePaths
import Combine
import ComposableArchitecture
import DataKit
import eRpKit
import Foundation
import IDP

struct RegisteredDevicesDomain: ReducerProtocol {
    typealias Store = StoreOf<Self>

    static func cleanup<T>() -> EffectTask<T> {
        EffectTask<T>.cancel(ids: Token.allCases)
    }

    enum Token: CaseIterable, Hashable {}

    struct State: Equatable {
        let profileId: UUID

        var destination: Destinations.State?

        var thisDeviceKeyIdentifier: String?

        var content: Content = .notLoaded

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

    struct Destinations: ReducerProtocol {
        enum State: Equatable {
            // sourcery: AnalyticsScreen = cardWall
            case idpCardWall(IDPCardWallDomain.State)
            // sourcery: AnalyticsScreen = alert
            case alert(ErpAlertState<RegisteredDevicesDomain.Action>)
        }

        enum Action: Equatable {
            case idpCardWallAction(IDPCardWallDomain.Action)
        }

        var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.idpCardWall,
                action: /Action.idpCardWallAction
            ) {
                IDPCardWallDomain()
            }
        }
    }

    enum Action: Equatable {
        case loadDevices
        case deleteDevice(String)

        case showCardWall(IDPCardWallDomain.State)

        case setNavigation(tag: Destinations.State.Tag?)
        case destination(Destinations.Action)

        case response(Response)

        enum Response: Equatable {
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

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    private var environment: Environment {
        .init(
            schedulers: schedulers,
            registeredDevicesService: registeredDevicesService,
            dateFormatter: dateFormatter
        )
    }

    struct Environment {
        let schedulers: Schedulers
        let registeredDevicesService: RegisteredDevicesService
        let dateFormatter: DateFormatter
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce(core)
            .ifLet(\.destination, action: /Action.destination) {
                Destinations()
            }
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadDevices:
            let currentState = (/State.Content.loaded).extract(from: state.content) ?? []
            state.content = .loading(currentState)
            return .merge(
                environment.getRegisteredDevices(profileId: state.profileId),
                environment.getDeviceId(for: state.profileId)
            )
        case let .response(.loadDevicesReceived(.success(entries))):
            state.content = .loaded(
                entries.pairingEntries
                    .map { ($0, dateFormatter) }
                    .map(State.Entry.init)
            )
            return .none
        case let .response(.loadDevicesReceived(.failure(error))):
            state.destination = .alert(.init(for: error))
            return .none
        case let .response(.deviceIdReceived(keyIdentifier)):
            state.thisDeviceKeyIdentifier = keyIdentifier
            return .none
        case let .showCardWall(cardWallState):
            state.destination = .idpCardWall(cardWallState)
            return .none
        case .setNavigation(tag: .none):
            state.destination = nil
            state.content = .notLoaded
            return .none
        case .setNavigation:
            return .none
        case let .destination(.idpCardWallAction(.delegate(idpCardWallDelegateAction))):
            switch idpCardWallDelegateAction {
            case .finished:
                state.destination = nil
                return .concatenate(
                    IDPCardWallDomain.cleanup(),
                    EffectTask(value: .loadDevices)
                )
            case .close:
                state.destination = nil
                return IDPCardWallDomain.cleanup()
            }
        case .destination(.idpCardWallAction):
            return .none
        case let .deleteDevice(device):
            return environment.deleteDevice(device, of: state.profileId)
                .eraseToEffect()
        case let .response(.deleteDeviceReceived(.failure(error))):
            state.destination = .alert(.init(for: error))
            return .none
        case .response(.deleteDeviceReceived(.success)):
            return environment.getRegisteredDevices(profileId: state.profileId)
        }
    }
}

extension RegisteredDevicesDomain.Environment {
    func getRegisteredDevices(profileId: UUID) -> EffectTask<RegisteredDevicesDomain.Action> {
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
            .eraseToEffect()
    }

    func getDeviceId(for profileId: UUID) -> EffectTask<RegisteredDevicesDomain.Action> {
        registeredDevicesService.deviceId(for: profileId)
            .map(RegisteredDevicesDomain.Action.Response.deviceIdReceived)
            .map(RegisteredDevicesDomain.Action.response)
            .receive(on: schedulers.main)
            .eraseToEffect()
    }

    func deleteDevice(_ deviceId: String, of profileId: UUID) -> EffectTask<RegisteredDevicesDomain.Action> {
        registeredDevicesService.deleteDevice(deviceId, of: profileId)
            .catchToEffect()
            .map(RegisteredDevicesDomain.Action.Response.deleteDeviceReceived)
            .map(RegisteredDevicesDomain.Action.response)
            .receive(on: schedulers.main)
            .eraseToEffect()
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
            destination: .idpCardWall(.init(profileId: UUID(),
                                            pin: .init(isDemoModus: false, transition: .fullScreenCover)))
        )

        static let store = store(for: state)

        static func store(
            for state: State
        ) -> Store {
            Store(initialState: state, reducer: EmptyReducer())
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
