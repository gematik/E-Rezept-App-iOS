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

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import FeatureCardWall
import FeatureHelpers
import Foundation
import Profiles
import SwiftUI

/// Domain for displaying prescription redemption codes
@Reducer
public struct CodeDomain {
    /// State for code display
    @ObservableState
    public struct State: Equatable {
        var displayMode = DisplayMode.manual
        var insuranceId: String?
        var euAccessCode: EuAccessCode?
        var countryCode: String
        var qrCodeImage: UIImage?
        var isLoading: Bool = true

        var minutesRemaining: Int {
            @Dependency(\.date) var date
            return CodeDomain.minutes(from: date.now, to: euAccessCode?.validUntil)
        }

        /// Boolean if the accessCode is expired
        public var isExpired: Bool {
            @Dependency(\.date) var date
            guard let validUntil = euAccessCode?.validUntil else { return true }
            return validUntil < date.now
        }

        @Shared(.selectedProfileId) var profileId
        /// Destination for navigation and modals
        @Presents public var destination: Destination.State?

        public enum DisplayMode: Equatable {
            case manual
            case qrCode
        }

        public init(
            displayMode: DisplayMode = DisplayMode.manual,
            insuranceId: String? = nil,
            euAccessCode: EuAccessCode? = nil,
            countryCode: String,
            isLoading: Bool = true
        ) {
            self.displayMode = displayMode
            self.insuranceId = insuranceId
            self.euAccessCode = euAccessCode
            self.countryCode = countryCode
            self.isLoading = isLoading
        }
    }

    /// Actions for code display
    public enum Action: Equatable {
        case task
        case toggleDisplayMode
        case refreshCode
        case generateQRCode(screenSize: CGSize)
        case speechButtonTapped(text: String)
        case response(Response)
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)

        public enum Response: Equatable {
            case profileReceived(Result<Profile?, LocalStoreError>)
            case qrCodeImageReceived(Result<UIImage?, EuCodeGenerationError>)
            case codeRefreshed(Result<EuAccessCode?, EuRedeemServiceError>)
        }

        public enum Delegate: Equatable {
            case close
            case takeReceipt
        }
    }

    /// Navigation and modal destinations
    @Reducer
    public enum Destination {
        // sourcery: AnalyticsScreen = alert
        /// alert destination
        @ReducerCaseEphemeral
        case alert(ErpAlertState<Alert>)

        /// all alert screens
        public enum Alert: Equatable {
            case refreshCode
        }
    }

    /// Initialize the domain
    public init() {}

    @Dependency(\.profilesStore) var profileStore: ProfilesStore
    @Dependency(\.euRedeemService) var euRedeemService: EuRedeemService
    @Dependency(\.euAccessCodeGenerator) var euAccessCodeGenerator: EuAccessCodeGenerator
    @Dependency(\.date) var date
    @Dependency(\.textToSpeechService) var textToSpeechService

    /// Reducer body
    public var body: some Reducer<State, Action> {
        Reduce(core)
            .ifLet(\.$destination, action: \.destination)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            return .merge(
                .run { [euAccessCode = state.euAccessCode] send in
                    if euAccessCode == nil {
                        await send(.refreshCode)
                    }
                },
                .run { [insuranceId = state.insuranceId, profileId = state.profileId] send in
                    if insuranceId == nil {
                        do {
                            let profile = try await profileStore.fetchProfile(profileId).async()
                            await send(.response(.profileReceived(.success(profile))))
                        } catch let error as LocalStoreError {
                            await send(.response(.profileReceived(.failure(error))))
                        }
                    }
                }
            )
        case let .response(.profileReceived(result)):
            switch result {
            case let .success(profile):
                state.insuranceId = profile?.insuranceId
            case let .failure(error):
                state.destination = .alert(ErpAlertState(for: error))
            }
            return .none
        case .toggleDisplayMode:
            switch state.displayMode {
            case .manual:
                state.displayMode = .qrCode
                if state.qrCodeImage == nil {
                    return .send(.generateQRCode(screenSize: CGSize(width: 200, height: 200)))
                }
            case .qrCode:
                state.displayMode = .manual
            }
            return .none
        case let .speechButtonTapped(text: text):
            try? textToSpeechService.speakText(text, state.countryCode)
            return .none
        case .refreshCode,
             .destination(.presented(.alert(.refreshCode))):
            return .run { [countryCode = state.countryCode, profileId = state.profileId] send in
                do {
                    let newCode = try await euRedeemService.grantEuAccessCode(
                        countryCode: countryCode,
                        profileId: profileId
                    )
                    await send(.response(.codeRefreshed(.success(newCode))))
                } catch let error as EuRedeemServiceError {
                    await send(.response(.codeRefreshed(.failure(error))))
                }
            }
        case let .generateQRCode(screenSize):
            guard let accessCode = state.euAccessCode?.accessCode,
                  let insuranceId = state.insuranceId else {
                state.displayMode = .manual
                return .send(.refreshCode)
            }
            let qrData = "\(insuranceId)|\(accessCode)"
            return .run { [qrData = qrData] send in
                do {
                    let result = try await euAccessCodeGenerator.generateQRCodeImage(qrData, screenSize)
                    await send(.response(.qrCodeImageReceived(.success(result))))
                } catch let error as EuCodeGenerationError {
                    await send(.response(.qrCodeImageReceived(.failure(error))))
                }
            }
        case let .response(.qrCodeImageReceived(result)):
            switch result {
            case let .success(image):
                state.qrCodeImage = image
            case let .failure(error):
                state.destination = .alert(ErpAlertState(for: error))
            }
            return .none
        case let .response(.codeRefreshed(.success(euAccessCode))):
            state.isLoading = false
            state.euAccessCode = euAccessCode
            state.qrCodeImage = nil

            if state.displayMode == .qrCode {
                return .send(.generateQRCode(screenSize: CGSize(width: 200, height: 200)))
            }
            return .none
        case let .response(.codeRefreshed(.failure(error))):
            state.isLoading = false
            switch error {
            case .euCodeGeneration:
                state.destination = .alert(Self.accessCodeError())
            default:
                state.destination = .alert(ErpAlertState(for: error))
            }
            return .none
        case .delegate, .destination:
            return .none
        }
    }

    static func minutes(
        from start: Date?,
        to end: Date?,
        calendar: Calendar = Calendar.current
    ) -> Int {
        guard let start, let end else {
            return 0
        }
        let minutes = calendar.dateComponents([.minute], from: start, to: end).minute
        return minutes ?? 0
    }

    static func accessCodeError() -> ErpAlertState<Destination.Alert> {
        ErpAlertState(
            title: { TextState(L10n.euredeemCodeAlertGenerateTitle) },
            actions: {
                ButtonState(role: .cancel) {
                    .init(L10n.alertBtnOk)
                }
                ButtonState(action: .refreshCode) {
                    .init(L10n.euredeemCodeAlertGenerateAgain)
                }
            },
            message: { TextState(L10n.euredeemCodeAlertGenerateMessage) }
        )
    }
}

extension CodeDomain {
    enum Dummies {
        static let state = State(countryCode: "De", isLoading: false)

        static let expiredState = State(
            displayMode: .manual,
            insuranceId: "M123456789",
            euAccessCode: EuAccessCode(),
            countryCode: "De",
            isLoading: false
        )

        static let store = StoreOf<CodeDomain>(
            initialState: state
        ) {
            CodeDomain()
        }

        static let expiredStore = StoreOf<CodeDomain>(
            initialState: expiredState
        ) {
            CodeDomain()
        }

        static func storeFor(_ state: State) -> StoreOf<CodeDomain> {
            Store(
                initialState: state
            ) {
                CodeDomain()
            }
        }
    }
}

extension CodeDomain.Destination.State: Equatable {}
extension CodeDomain.Destination.Action: Equatable {}
