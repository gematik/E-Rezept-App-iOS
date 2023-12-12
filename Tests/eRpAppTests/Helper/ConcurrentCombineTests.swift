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
import Dependencies
@testable import eRpApp
import Nimble
import XCTest

@MainActor
final class ConcurrentCombineTests: XCTestCase {
    func testPublisherToConcurrent() async throws {
        let publisher = [1, 2, 3].publisher
        let result = try await publisher.async()
        expect(result) == 1

        let emptySequence: [Int] = []
        let emptyPublisher = emptySequence.publisher
        var runSuccess = false
        do {
            _ = try await emptyPublisher.async()
        } catch {
            guard let error = error as? AsyncError
            else { Nimble.fail("unexpected error")
                return
            }
            expect(error) == .finishedWithoutValue
            runSuccess = true
        }
        expect(runSuccess) == true
    }

    func testPublisherToConcurrent_embedError() async throws {
        enum InnerError: Equatable, Error {
            case error
        }
        enum OuterError: Equatable, Error {
            case inner(InnerError)
        }

        let publisher = Fail<Any, InnerError>(error: InnerError.error).eraseToAnyPublisher()

        var runSuccess = false
        do {
            _ = try await publisher.async(/OuterError.inner)
        } catch {
            guard let error = error as? OuterError
            else { Nimble.fail("unexpected error")
                return
            }
            expect(error).to(equal(OuterError.inner(InnerError.error)))
            runSuccess = true
        }
        expect(runSuccess) == true
    }

    func testConcurrentToPublisher() throws {
        func fetchWeatherHistory() async -> [Int] {
            let task = Task.detached {
                (1 ... 10).map { _ in Int.random(in: -10 ... 30) }
            }
            return await task.value
        }

        let publisher = Future<[Int], Never> {
            await fetchWeatherHistory()
        }
        let exp = expectation(description: "Publisher has run")

        var runSuccess = false
        var valuesReceived = 0
        let cancellable = publisher
            .sink { temperatures in
                expect(temperatures.count) == 10
                exp.fulfill()
                valuesReceived += 1
                runSuccess = true
            }

        waitForExpectations(timeout: 2)
        expect(valuesReceived) == 1
        expect(runSuccess) == true
        cancellable.cancel()
    }

    func testConcurrentToPublisher_withEscapedDependencies() throws {
        func fetchWeatherHistory(dateGenerator: DateGenerator) async -> Date {
            let task = Task.detached {
                dateGenerator()
            }
            return await task.value
        }

        let publisher = withDependencies { dependencies in
            dependencies.date = .constant(.init(timeIntervalSinceReferenceDate: 0))
        } operation: {
            @Dependency(\.date) var date
            return Future<Date, Never>.createWithEscapedDependencies {
                await fetchWeatherHistory(dateGenerator: date)
            }
        }

        // Publisher should emit Date(timeIntervalSinceReferenceDate: 0)
        let exp = expectation(description: "Publisher has run")

        var runSuccess = false
        var valuesReceived = 0
        let cancellable = publisher
            .sink { date in
                expect(date) == Date(timeIntervalSinceReferenceDate: 0)
                exp.fulfill()
                valuesReceived += 1
                runSuccess = true
            }

        waitForExpectations(timeout: 2)
        expect(valuesReceived) == 1
        expect(runSuccess) == true
        cancellable.cancel()

        // Publisher should emit Date(timeIntervalSinceReferenceDate: 0) again
        // albeit when `DateGeneratorDependency` changed
        withDependencies { dependencies in
            dependencies.date = .constant(.init(timeIntervalSinceReferenceDate: 10))
        } operation: {
            let exp2 = expectation(description: "Publisher has run again with altered dependencies")
            var runSuccess2 = false
            var valuesReceived2 = 0
            let cancellable2 = publisher
                .sink { date in
                    expect(date) == Date(timeIntervalSinceReferenceDate: 0)
                    exp2.fulfill()
                    valuesReceived2 += 1
                    runSuccess2 = true
                }

            waitForExpectations(timeout: 2)
            expect(valuesReceived2) == 1
            expect(runSuccess2) == true
            cancellable2.cancel()

            @Dependency(\.date) var date
            expect(date()) == Date(timeIntervalSinceReferenceDate: 10)
        }
    }
}
