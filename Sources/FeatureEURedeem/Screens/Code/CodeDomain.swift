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
import Foundation
import SwiftUI

/// Domain for displaying prescription redemption codes
@Reducer
public struct CodeDomain {
    /// State for code display
    @ObservableState
    public struct State: Equatable {
        var displayMode = DisplayMode.manual
        var insuranceNumber: String
        var exchangeCode: String
        var qrCodeImage: UIImage?
        var isExpired = false
        var expirationDate: Date?

        public enum DisplayMode: Equatable {
            case manual
            case qrCode
        }

        public init(
            displayMode: DisplayMode = DisplayMode.manual,
            insuranceNumber: String = "M123456789",
            exchangeCode: String = "A1b2C3",
            qrCodeImage: UIImage? = nil,
            isExpired: Bool = false,
            expirationDate: Date? = nil
        ) {
            self.displayMode = displayMode
            self.insuranceNumber = insuranceNumber
            self.exchangeCode = exchangeCode
            self.qrCodeImage = qrCodeImage
            self.isExpired = isExpired
            self.expirationDate = expirationDate
        }
    }

    /// Actions for code display
    public enum Action: Equatable {
        case toggleDisplayMode
        case refreshCode
        case generateQRCode(screenSize: CGSize)
        case checkExpiration
        case response(Response)
        case delegate(Delegate)

        public enum Response: Equatable {
            case qrCodeImageReceived(UIImage?)
            case codeRefreshed(insuranceNumber: String, exchangeCode: String)
            case codeExpired
        }

        public enum Delegate: Equatable {
            case close
            case takeReceipt
        }
    }

    /// Initialize the domain
    public init() {}

    /// Reducer body
    public var body: some Reducer<State, Action> {
        Reduce(self.core)
    }

    private func core(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .toggleDisplayMode:
            return handleToggleDisplayMode(state: &state)
        case .refreshCode:
            return handleRefreshCode()
        case let .generateQRCode(screenSize):
            return handleGenerateQRCode(state: state, screenSize: screenSize)
        case .checkExpiration:
            return handleCheckExpiration(state: state)
        case let .response(.qrCodeImageReceived(image)):
            state.qrCodeImage = image
            return .none
        case let .response(.codeRefreshed(insuranceNumber, exchangeCode)):
            return handleCodeRefreshed(state: &state, insuranceNumber: insuranceNumber, exchangeCode: exchangeCode)
        case .response(.codeExpired):
            state.isExpired = true
            return .none
        case .delegate:
            return .none
        }
    }

    private func handleToggleDisplayMode(state: inout State) -> Effect<Action> {
        switch state.displayMode {
        case .manual:
            state.displayMode = .qrCode
            if state.qrCodeImage == nil {
                return .send(.generateQRCode(screenSize: CGSize(width: 300, height: 300)))
            }
        case .qrCode:
            state.displayMode = .manual
        }
        return .none
    }

    private func handleRefreshCode() -> Effect<Action> {
        let newInsuranceNumber = generateRandomInsuranceNumber()
        let newExchangeCode = generateRandomExchangeCode()

        return .send(.response(.codeRefreshed(
            insuranceNumber: newInsuranceNumber,
            exchangeCode: newExchangeCode
        )))
    }

    private func handleGenerateQRCode(state: State, screenSize: CGSize) -> Effect<Action> {
        let qrData = "\(state.insuranceNumber)|\(state.exchangeCode)"

        return .run { send in
            try? await Task.sleep(for: .seconds(1))
            let qrImage = await generateQRCodeImage(from: qrData, size: screenSize)
            await send(.response(.qrCodeImageReceived(qrImage)))
        }
    }

    private func handleCheckExpiration(state: State) -> Effect<Action> {
        if let expirationDate = state.expirationDate, Date() > expirationDate {
            return .send(.response(.codeExpired))
        }
        return .none
    }

    private func handleCodeRefreshed(
        state: inout State,
        insuranceNumber: String,
        exchangeCode: String
    ) -> Effect<Action> {
        state.insuranceNumber = insuranceNumber
        state.exchangeCode = exchangeCode
        state.isExpired = false
        state.expirationDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())
        state.qrCodeImage = nil

        if state.displayMode == .qrCode {
            return .send(.generateQRCode(screenSize: CGSize(width: 300, height: 300)))
        }
        return .none
    }

    /// Will be replaced later by an implementation using a a real service
    private func generateRandomInsuranceNumber() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        guard let randomLetter = letters.randomElement() else {
            return "M123456789" // Fallback
        }
        let numbersString = (0 ..< 9).compactMap { _ in numbers.randomElement() }.map(String.init).joined()
        return "\(randomLetter)\(numbersString)"
    }

    /// Will be replaced later by an implementation using a a real service
    private func generateRandomExchangeCode() -> String {
        (0 ..< 6)
            .compactMap { index in
                if index % 2 == 0 {
                    // Even positions: letters
                    return "ABCDEFGHIJKLMNOPQRSTUVWXYZ".randomElement().map(String.init)
                } else {
                    // Odd positions: numbers
                    return "0123456789".randomElement().map(String.init)
                }
            }
            .joined()
    }

    /// Will be replaced later by an implementation using a a real service
    private func generateQRCodeImage(from data: String, size: CGSize) async -> UIImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
                    continuation.resume(returning: nil)
                    return
                }

                let data = Data(data.utf8)
                filter.setValue(data, forKey: "inputMessage")

                guard let outputImage = filter.outputImage else {
                    continuation.resume(returning: nil)
                    return
                }

                let scaleX = size.width / outputImage.extent.size.width
                let scaleY = size.height / outputImage.extent.size.height
                let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                let transformedImage = outputImage.transformed(by: transform)

                let context = CIContext()
                guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
                    continuation.resume(returning: nil)
                    return
                }

                let uiImage = UIImage(cgImage: cgImage)
                continuation.resume(returning: uiImage)
            }
        }
    }
}

extension CodeDomain {
    enum Dummies {
        static let state = State()

        static let expiredState = State(
            displayMode: .manual,
            insuranceNumber: "M123456789",
            exchangeCode: "A1b2C3",
            qrCodeImage: nil,
            isExpired: true,
            expirationDate: Calendar.current.date(byAdding: .minute, value: -1, to: Date())
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
