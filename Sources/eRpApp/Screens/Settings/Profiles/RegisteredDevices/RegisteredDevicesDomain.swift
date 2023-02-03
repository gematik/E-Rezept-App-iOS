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

enum RegisteredDevicesDomain {
    typealias Store = ComposableArchitecture.Store<State, Action>
    typealias Reducer = ComposableArchitecture.AnyReducer<State, Action, Environment>

    static func cleanup<T>() -> Effect<T, Never> {
        Effect.cancel(id: Token.self)
    }

    enum Token: CaseIterable, Hashable {}

    enum Route: Equatable {
        case cardWall(IDPCardWallDomain.State)
        case alert(ErpAlertState<Action>)
    }

    struct State: Equatable {
        let profileId: UUID

        var route: Route?

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

    enum Action: Equatable {
        case loadDevices
        case loadDevicesReceived(Result<PairingEntries, RegisteredDevicesServiceError>)
        case deleteDevice(String)
        case deleteDeviceReceived(Result<Bool, RegisteredDevicesServiceError>)

        case showCardWall(IDPCardWallDomain.State)
        case idpCardWall(action: IDPCardWallDomain.Action)

        case setNavigation(tag: Route.Tag?)
        case deviceIdReceived(String?)
    }

    // sourcery: CodedError = "017"
    enum Error: Swift.Error, Equatable {
        // sourcery: errorCode = "01"
        case generic(String)
    }

    struct Environment {
        let schedulers: Schedulers
        let userSession: UserSession
        let userSessionProvider: UserSessionProvider
        let secureEnclaveSignatureProvider: SecureEnclaveSignatureProvider
        let nfcSignatureProvider: NFCSignatureProvider
        let sessionProvider: ProfileBasedSessionProvider
        let accessibilityAnnouncementReceiver: (String) -> Void

        let registeredDevicesService: RegisteredDevicesService

        var dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            return dateFormatter
        }()
    }

    static let domainReducer = Reducer { state, action, environment in
        switch action {
        case .loadDevices:
            let currentState = (/State.Content.loaded).extract(from: state.content) ?? []
            state.content = .loading(currentState)
            return Effect.merge(
                environment.getRegisteredDevices(profileId: state.profileId),
                environment.getDeviceId(for: state.profileId)
            )
        case let .loadDevicesReceived(.success(entries)):
            state.content = .loaded(
                entries.pairingEntries
                    .map { ($0, environment.dateFormatter) }
                    .map(State.Entry.init)
            )
            return .none
        case let .loadDevicesReceived(.failure(error)):
            state.route = .alert(.init(for: error))
            return .none
        case let .deviceIdReceived(keyIdentifier):
            state.thisDeviceKeyIdentifier = keyIdentifier
            return .none
        case let .showCardWall(cardWallState):
            state.route = .cardWall(cardWallState)
            return .none
        case .setNavigation(tag: .none):
            state.route = nil
            state.content = .notLoaded
            return .none
        case .setNavigation:
            return .none
        case .idpCardWall(action: .finished):
            state.route = nil
            return .concatenate(
                IDPCardWallDomain.cleanup(),
                Effect(value: .loadDevices)
            )
        case .idpCardWall(action: .close):
            state.route = nil
            return IDPCardWallDomain.cleanup()
        case .idpCardWall:
            return .none
        case let .deleteDevice(device):
            let profileId = state.profileId
            return environment.deleteDevice(device, of: state.profileId)
                .eraseToEffect()
        case let .deleteDeviceReceived(.failure(error)):
            state.route = .alert(.init(for: error))
            return .none
        case .deleteDeviceReceived(.success):
            return environment.getRegisteredDevices(profileId: state.profileId)
        }
    }

    static let reducer: Reducer = .combine(
        idpCardWallReducer,
        domainReducer
    )
    .debugActions()

    static let idpCardWallReducer: Reducer =
        IDPCardWallDomain.reducer._pullback(
            state: (\State.route).appending(path: /RegisteredDevicesDomain.Route.cardWall),
            action: /RegisteredDevicesDomain.Action.idpCardWall(action:)
        ) {
            .init(
                schedulers: $0.schedulers,
                userSession: $0.userSession,
                userSessionProvider: $0.userSessionProvider,
                secureEnclaveSignatureProvider: $0.secureEnclaveSignatureProvider,
                nfcSignatureProvider: $0.nfcSignatureProvider,
                sessionProvider: $0.sessionProvider,
                accessibilityAnnouncementReceiver: $0.accessibilityAnnouncementReceiver
            )
        }
}

extension RegisteredDevicesDomain.Environment {
    func getRegisteredDevices(profileId: UUID) -> Effect<RegisteredDevicesDomain.Action, Never> {
        registeredDevicesService.registeredDevices(for: profileId)
            .map { RegisteredDevicesDomain.Action.loadDevicesReceived(.success($0)) }
            .catch { error -> AnyPublisher<RegisteredDevicesDomain.Action, Never> in
                if RegisteredDevicesServiceError.missingAuthentication == error {
                    return registeredDevicesService.cardWall(for: profileId)
                        .map(RegisteredDevicesDomain.Action.showCardWall)
                        .eraseToAnyPublisher()
                }
                return Just(RegisteredDevicesDomain.Action.loadDevicesReceived(.failure(error)))
                    .eraseToAnyPublisher()
            }
            .receive(on: schedulers.main)
            .eraseToEffect()
    }

    func getDeviceId(for profileId: UUID) -> Effect<RegisteredDevicesDomain.Action, Never> {
        registeredDevicesService.deviceId(for: profileId)
            .map(RegisteredDevicesDomain.Action.deviceIdReceived)
            .receive(on: schedulers.main)
            .eraseToEffect()
    }

    func deleteDevice(_ deviceId: String, of profileId: UUID) -> Effect<RegisteredDevicesDomain.Action, Never> {
        registeredDevicesService.deleteDevice(deviceId, of: profileId)
            .catchToEffect()
            .map(RegisteredDevicesDomain.Action.deleteDeviceReceived)
            .receive(on: schedulers.main)
            .eraseToEffect()
    }
}

extension RegisteredDevicesDomain {
    enum Dummies {
        static let state = State(profileId: UUID())
        static let loadingState = State(
            profileId: UUID(),
            route: nil,
            content: .loading([])
        )
        static let devicesState = State(
            profileId: UUID(),
            route: nil,
            thisDeviceKeyIdentifier: "a98765432",
            content: .loaded([
                State.Entry(PairingEntry.Dummies.deviceA),
                State.Entry(PairingEntry.Dummies.deviceB),
            ])
        )
        static let loadedNoDevices = State(
            profileId: UUID(),
            route: nil,
            thisDeviceKeyIdentifier: nil,
            content: .loaded([])
        )
        static let loadingWithDevicesState = State(
            profileId: UUID(),
            route: nil,
            content: .loading([
                State.Entry(PairingEntry.Dummies.deviceA),
                State.Entry(PairingEntry.Dummies.deviceB),
            ])
        )
        static let cardWallState = State(
            profileId: UUID(),
            route: .cardWall(.init(profileId: UUID(),
                                   pin: .init(isDemoModus: false, transition: .fullScreenCover)))
        )

        static let environment = Environment(
            schedulers: Schedulers(),
            userSession: DummySessionContainer(),
            userSessionProvider: DummyUserSessionProvider(),
            secureEnclaveSignatureProvider: DummySecureEnclaveSignatureProvider(),
            nfcSignatureProvider: DemoSignatureProvider(),
            sessionProvider: DummyProfileBasedSessionProvider(),
            accessibilityAnnouncementReceiver: { _ in },
            registeredDevicesService: DefaultRegisteredDevicesService(userSessionProvider: DummyUserSessionProvider())
        )

        static let store = Store(initialState: state,
                                 reducer: reducer,
                                 environment: environment)

        static func store(for state: State) -> Store {
            Store(initialState: state, reducer: .empty, environment: environment)
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
    // swiftlint:disable force_try
    enum Dummies {
        static let signedPairingDataA = SignedPairingData(
            originalPairingData: PairingData.Dummies.pairingDataA,
            signedPairingData: {
                let pairingDataHeader = JWT.Header(alg: JWT.Algorithm.bp256r1, typ: "JWT")
                return try! JWT(header: pairingDataHeader, payload: PairingData.Dummies.pairingDataA)
            }()
        )
        static let signedPairingDataB = SignedPairingData(
            originalPairingData: PairingData.Dummies.pairingDataB,
            signedPairingData: {
                let pairingDataHeader = JWT.Header(alg: JWT.Algorithm.bp256r1, typ: "JWT")
                return try! JWT(header: pairingDataHeader, payload: PairingData.Dummies.pairingDataB)
            }()
        )
    }
}
