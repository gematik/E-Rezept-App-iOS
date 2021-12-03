//
//  Copyright (c) 2021 gematik GmbH
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
import UIKit

final class UIApplicationOpenURLMock {
    // MARK: - canOpenURL

    var canOpenURLUrlCallsCount = 0
    var canOpenURLUrlCalled: Bool {
        canOpenURLUrlCallsCount > 0
    }

    var canOpenURLUrlReceivedUrl: URL?
    var canOpenURLUrlReceivedInvocations: [URL] = []
    var canOpenURLUrlReturnValue: Bool!
    var canOpenURLUrlClosure: ((URL) -> Bool)?

    func canOpenURL(url: URL) -> Bool {
        canOpenURLUrlCallsCount += 1
        canOpenURLUrlReceivedUrl = url
        canOpenURLUrlReceivedInvocations.append(url)
        return canOpenURLUrlClosure.map { $0(url) } ?? canOpenURLUrlReturnValue
    }

    // MARK: - openURL

    var openURLOptionsCompletionCallsCount = 0
    var openURLOptionsCompletionCalled: Bool {
        openURLOptionsCompletionCallsCount > 0
    }

    // swiftlint:disable large_tuple
    var openURLOptionsCompletionReceivedArguments: (
        url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completion: ((Bool) -> Void)?
    )?
    var openURLOptionsCompletionReceivedInvocations: [
        (url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any],
         completion: ((Bool) -> Void)?)
    ] = []
    var openURLOptionsCompletionClosure: ((URL, [UIApplication.OpenExternalURLOptionsKey: Any], ((Bool) -> Void)?)
        -> Void)?

    func openURL(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completion: ((Bool) -> Void)?) {
        openURLOptionsCompletionCallsCount += 1
        openURLOptionsCompletionReceivedArguments = (url: url, options: options, completion: completion)
        openURLOptionsCompletionReceivedInvocations.append((url: url, options: options, completion: completion))
        openURLOptionsCompletionClosure?(url, options, completion)
    }
}
