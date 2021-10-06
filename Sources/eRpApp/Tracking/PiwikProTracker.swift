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
import PiwikPROSDK

class PiwikProTracker: Tracker {
    private var siteId: String
    private var baseURL: URL
    private let tracker: PiwikTracker?
    private var optIn = false
    private var currentOptOutSetting: AnyPublisher<Bool, Never>
    var cancellables = Set<AnyCancellable>()

    init(optOutSetting: AnyPublisher<Bool, Never>) {
        siteId = ""
        // swiftlint:disable:next force_unwrapping
        baseURL = URL(string: "https://gematik.piwik.pro")!

        // [REQ:gemSpec_eRp_FdV:A_19095] user session is randomly created by piwik - See visitorID.
        // [REQ:gemSpec_eRp_FdV:A_19096] new visitorID is generated when app is reinstalled.
        tracker = PiwikTracker.sharedInstance(siteID: siteId, baseURL: baseURL)

        currentOptOutSetting = optOutSetting
        currentOptOutSetting.sink { optIn in
            self.optOut = !optIn
        }
        .store(in: &cancellables)
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    var optOut: Bool {
        get {
            tracker?.optOut ?? true
        }
        set {
            if newValue {
                tracker?.deleteQueuedEvents()
            } else {
                trackAppInstall()
            }
            tracker?.optOut = newValue
        }
    }

    /// This will send an "app installed" event to the server but only once.
    func trackAppInstall() {
        if !UserDefaults.standard.appInstallSent {
            tracker?.sendApplicationDownload()
            UserDefaults.standard.setValue(true, forKey: UserDefaults.kAppInstallSent)
        }
    }
}
