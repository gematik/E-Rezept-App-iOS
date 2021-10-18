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

import ComposableArchitecture
import eRpLocalStorage
import IDP
import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, Routing {
    var mainWindow,
        authenticationWindow: UIWindow?

    var routerStore: RouterStore<AppStartDomain.State, AppStartDomain.Action, AppStartDomain.Environment>?

    func scene(_ scene: UIScene,
               willConnectTo _: UISceneSession,
               options _: UIScene.ConnectionOptions) {
        // As soon as AppContainer is removed, the construction of ChangeableUserSessionContainer will be here
        let sessionContainer = AppContainer.shared.userSessionContainer

        let tracker = PiwikProTracker(
            optOutSetting: UserDefaults.standard.publisher(for: \UserDefaults.kAppTrackingAllowed).eraseToAnyPublisher()
        )

        #if ENABLE_DEBUG_VIEW && targetEnvironment(simulator)
        // swiftlint:disable:next trailing_closure
        let signatureProvider = DefaultSecureEnclaveSignatureProvider(
            storage: sessionContainer.userSession.secureUserStore,
            privateKeyContainerProvider: {
                try PrivateKeyContainer.createFromKeyChain(with: $0)
            }
        )
        #else
        let signatureProvider = DefaultSecureEnclaveSignatureProvider(
            storage: sessionContainer.userSession.secureUserStore
        )
        #endif
        // This must be raw userDefaults access, demo session should *not* interfere with user authentication
        let standardUserDataStore = UserDefaultsStore(userDefaults: .standard)

        let routableAppStore = RouterStore(
            initialState: .init(),
            reducer: AppStartDomain.reducer,
            environment: AppStartDomain.Environment(
                appVersion: AppVersion.current,
                router: self,
                userSessionContainer: sessionContainer,
                userSession: sessionContainer.userSession,
                // This must be raw userDefaults access, demo session should *not* interfere with user authentication
                userDataStore: standardUserDataStore,
                schedulers: Schedulers(),
                fhirDateFormatter: AppContainer.shared.fhirDateFormatter,
                serviceLocator: AppContainer.shared.serviceLocator,
                accessibilityAnnouncementReceiver: { message in
                    UIAccessibility.post(notification: .announcement,
                                         argument: message)
                },
                tracker: tracker,
                signatureProvider: signatureProvider,
                appSecurityManager: DefaultAppSecurityManager(keychainAccess: SystemKeychainAccessHelper()),
                authenticationChallengeProvider: BiometricsAuthenticationChallengeProvider()
            ),
            router: AppStartDomain.router
        )

        routerStore = routableAppStore

        if let windowScene = scene as? UIWindowScene {
            authenticationWindow = UIWindow(windowScene: windowScene)
            mainWindow = UIWindow(windowScene: windowScene)
            mainWindow?.rootViewController = UIHostingController(
                rootView: AppStartView(store: routableAppStore.wrappedStore)
            )
            mainWindow?.makeKeyAndVisible()
        }
    }

    func routeTo(_ endpoint: Endpoint) {
        routerStore?.route(to: endpoint)
    }

    func sceneDidDisconnect(_: UIScene) {}

    func sceneDidBecomeActive(_: UIScene) {}

    func sceneWillResignActive(_: UIScene) {}

    func sceneWillEnterForeground(_: UIScene) {
        removeBlurOverlayFromWindow()
        // This must be raw userDefaults access, demo session should *not* interfere with user authentication
        let standardUserDataStore = UserDefaultsStore(userDefaults: .standard)

        let authenticationProvider = AppAuthenticationDomain.DefaultAuthenticationProvider(
            userDataStore: standardUserDataStore
        )
        let appAuthenticationStore = Store(
            initialState: AppAuthenticationDomain.State(),
            reducer: AppAuthenticationDomain.reducer,
            environment: AppAuthenticationDomain.Environment(
                userDataStore: standardUserDataStore,
                schedulers: Schedulers(),
                appAuthenticationProvider: authenticationProvider,
                appSecurityPasswordManager: DefaultAppSecurityManager(keychainAccess: SystemKeychainAccessHelper()),
                authenticationChallengeProvider: BiometricsAuthenticationChallengeProvider()
            ) { [weak self] in
                guard let self = self else { return }
                self.mainWindow?.accessibilityElementsHidden = false
                self.mainWindow?.makeKeyAndVisible()
                // background color is lost after window switch, reset it to black
                self.mainWindow?.backgroundColor = UIColor.black
                self.authenticationWindow?.rootViewController = nil
            }
        )

        authenticationWindow?.rootViewController = UIHostingController(
            // [REQ:gemSpec_BSI_FdV:A_20834] mandatory app authentication
            rootView: AppAuthenticationView(store: appAuthenticationStore)
        )
        mainWindow?.accessibilityElementsHidden = true
        authenticationWindow?.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_: UIScene) {
        addBlurOverlayToWindow()
    }

    func scene(_: UIScene, continue userActivity: NSUserActivity) {
        switch userActivity.activityType {
        case NSUserActivityTypeBrowsingWeb:
            guard let url = userActivity.webpageURL else { return }
            routeTo(.universalLink(url))
        default:
            break
        }
    }

    private func addBlurOverlayToWindow() {
        guard let mainWindow = mainWindow else { return }
        blurEffectView.frame = mainWindow.frame
        mainWindow.addSubview(blurEffectView)
    }

    private func removeBlurOverlayFromWindow() {
        blurEffectView.removeFromSuperview()
    }

    lazy var blurEffectView: UIView = {
        UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    }()
}
