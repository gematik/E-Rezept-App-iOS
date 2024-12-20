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

import Combine
import Dependencies
@testable import eRpFeatures
import eRpKit
import Nimble
import XCTest

@MainActor
final class DefaultInternalCommunicationProtocolTests: XCTestCase {
    var mockUserDataStore: MockUserDataStore!

    override func setUp() {
        super.setUp()

        mockUserDataStore = MockUserDataStore()
    }

    func testLoadWithNewInstall() async throws {
        // given
        // no InternalCommunications are read
        mockUserDataStore.readInternalCommunications = Just([]).eraseToAnyPublisher()
        // onboardingDate is Today
        mockUserDataStore.onboardingDate = Just(Date()).eraseToAnyPublisher()
        // hideWelcomeMessage is false because new install
        mockUserDataStore.hideWelcomeMessage = Just(false).eraseToAnyPublisher()

        let internalCommunicationsRepository = InternalCommunicationsRepository {
            [Self.Fixtures.internalCommunicationMessage02]
        }

        let sut = DefaultInternalCommunication(
            userDataStore: mockUserDataStore,
            internalCommunicationsRepository: internalCommunicationsRepository
        )

        // when
        let result = try await sut.load()

        // then
        // expect to get 2 Messages (Welcome message and Changelog 1.27.0)
        let messages = result.elements.flatMap(\.messages)
        expect(messages.count) == 2

        // expect that only the version numbers ["1.27.0", "0.0.0"] are included
        expect(messages.compactMap(\.version).elementsEqual(["1.27.0", "0.0.0"])) == true
    }

    func testLoadWithWithUpdatedOldApp() async throws {
        // given
        // no InternalCommunications are read
        mockUserDataStore.readInternalCommunications = Just([]).eraseToAnyPublisher()
        // onboardingDate is Today
        mockUserDataStore.onboardingDate = Just(Date()).eraseToAnyPublisher()
        // hideWelcomeMessage is true because updated old app
        mockUserDataStore.hideWelcomeMessage = Just(true).eraseToAnyPublisher()

        let internalCommunicationsRepository = InternalCommunicationsRepository {
            [Self.Fixtures.internalCommunicationMessage02]
        }

        let sut = DefaultInternalCommunication(
            userDataStore: mockUserDataStore,
            internalCommunicationsRepository: internalCommunicationsRepository
        )

        // when
        let result = try await sut.load()

        // then
        // expect to get 1 Messages (only Welcome message)
        let messages = result.elements.flatMap(\.messages)
        expect(messages.count) == 1
        // expect first message to be Changelog 1.27.0
        expect(messages[0].version) == "1.27.0"
    }

    func testLoadUnreadInternalCommunicationsCount() async throws {
        // given
        // no InternalCommunications are read
        mockUserDataStore.readInternalCommunications = Just([]).eraseToAnyPublisher()
        // onboardingDate is Today
        mockUserDataStore.onboardingDate = Just(Date()).eraseToAnyPublisher()
        // hideWelcomeMessage is false because new install
        mockUserDataStore.hideWelcomeMessage = Just(false).eraseToAnyPublisher()

        let internalCommunicationsRepository = InternalCommunicationsRepository {
            [Self.Fixtures.internalCommunicationMessage02]
        }

        let sut = DefaultInternalCommunication(
            userDataStore: mockUserDataStore,
            internalCommunicationsRepository: internalCommunicationsRepository
        )

        // then
        for try await messages in sut.loadUnreadInternalCommunicationsCount() {
            // expect 2 unread message because of the WelcomeMessage and ChangelogMessage
            expect(messages) == 2
        }
    }
}

extension DefaultInternalCommunicationProtocolTests {
    enum Fixtures {
        static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "dd.MM.yyyy HH:mm"
            return formatter
        }()

        static let internalCommunicationMessage02 = InternalCommunication.Message(
            id: "2",
            timestamp: Self.dateFormatter.date(from: "12.12.2024 08:00")!,
            // swiftlint:disable:next line_length
            text: "Wir haben folgende Verbesserungen mitgebracht:\n\n1. Sie können sich auch bei gescannten Rezepten an die Einnahme erinnern lassen\n2. Bei Anmeldung mit der KassenApp wird nun die ausgewählte Kasse für Folgeanmeldungen gespeichert \n3. Eine wichtige Warnung für PKV-Versicherte, damit nicht versehentlich Abrechnungsbelege gelöscht werden\n4. Verbesserte Apothekensuche per Kartenansicht",
            version: "1.27.0"
        )
    }
}
