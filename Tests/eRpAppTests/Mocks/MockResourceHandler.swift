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

import Combine
@testable import eRpFeatures
import UIKit

// MARK: - MockResourceHandler -

final class MockResourceHandler: ResourceHandler {
    // MARK: - canOpenURL

    var canOpenURLCallsCount = 0
    var canOpenURLCalled: Bool {
        canOpenURLCallsCount > 0
    }

    var canOpenURLReceivedUrl: URL?
    var canOpenURLReceivedInvocations: [URL] = []
    var canOpenURLReturnValue: Bool!
    var canOpenURLClosure: ((URL) -> Bool)?

    func canOpenURL(_ url: URL) -> Bool {
        canOpenURLCallsCount += 1
        canOpenURLReceivedUrl = url
        canOpenURLReceivedInvocations.append(url)
        return canOpenURLClosure.map { $0(url) } ?? canOpenURLReturnValue
    }

    // MARK: - open

    var openCallsCount = 0
    var openCalled: Bool {
        openCallsCount > 0
    }

    var openReceivedUrl: URL?
    var openReceivedInvocations: [URL] = []
    var openClosure: ((URL) -> Void)?

    func open(_ url: URL) {
        openCallsCount += 1
        openReceivedUrl = url
        openReceivedInvocations.append(url)
        openClosure?(url)
    }

    // MARK: - open

    var openOptionsCompletionHandlerCallsCount = 0
    var openOptionsCompletionHandlerCalled: Bool {
        openOptionsCompletionHandlerCallsCount > 0
    }

    var openOptionsCompletionHandlerReceivedArguments: (
        url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completion: ((Bool) -> Void)?
    )?
    #if compiler(>=6.0)
    var openOptionsCompletionHandlerReceivedInvocations: [(url: URL,
                                                           options: [UIApplication.OpenExternalURLOptionsKey: Any],
                                                           completion: (@MainActor @Sendable (Bool) -> Void)?)] = []
    var openOptionsCompletionHandlerClosure: ((URL, [UIApplication.OpenExternalURLOptionsKey: Any],
                                               (@MainActor @Sendable (Bool) -> Void)?)
            -> Void)?

    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: (@MainActor @Sendable (Bool) -> Void)?
    ) {
        openOptionsCompletionHandlerCallsCount += 1
        openOptionsCompletionHandlerReceivedArguments = (url: url, options: options, completion: completion)
        openOptionsCompletionHandlerReceivedInvocations.append((url: url, options: options, completion: completion))
        openOptionsCompletionHandlerClosure?(url, options, completion)
    }
    #else
    var openOptionsCompletionHandlerReceivedInvocations: [(url: URL,
                                                           options: [UIApplication.OpenExternalURLOptionsKey: Any],
                                                           completion: ((Bool) -> Void)?)] = []
    var openOptionsCompletionHandlerClosure: ((URL, [UIApplication.OpenExternalURLOptionsKey: Any],
                                               ((Bool) -> Void)?)
            -> Void)?

    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: ((Bool) -> Void)?
    ) {
        openOptionsCompletionHandlerCallsCount += 1
        openOptionsCompletionHandlerReceivedArguments = (url: url, options: options, completion: completion)
        openOptionsCompletionHandlerReceivedInvocations.append((url: url, options: options, completion: completion))
        openOptionsCompletionHandlerClosure?(url, options, completion)
    }
    #endif
}
