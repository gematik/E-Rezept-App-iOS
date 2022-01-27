//
//  Copyright (c) 2022 gematik GmbH
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
import eRpKit
import eRpLocalStorage
import IDP
import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, Routing {
    var mainWindow: UIWindow?
    var authenticationWindow: UIWindow?
    let coreDataControllerFactory: CoreDataControllerFactory = LocalStoreFactory()

    var routerStore: RouterStore<AppStartDomain.State, AppStartDomain.Action, AppStartDomain.Environment>?

    func scene(_ scene: UIScene,
               willConnectTo _: UISceneSession,
               options _: UIScene.ConnectionOptions) {
        let routableAppStore = RouterStore(
            initialState: .init(),
            reducer: AppStartDomain.reducer,
            environment: environment(),
            router: AppStartDomain.router
        )

        routerStore = routableAppStore

        if let windowScene = scene as? UIWindowScene {
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

    func sceneWillEnterForeground(_ scene: UIScene) {
        removeBlurOverlayFromWindow()

        guard let windowScene = scene as? UIWindowScene else {
            // prevent using the app if authentication view can't be presented
            mainWindow?.rootViewController = nil
            return
        }

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
                self.authenticationWindow = nil
            }
        )

        mainWindow?.accessibilityElementsHidden = true
        authenticationWindow = UIWindow(windowScene: windowScene)
        authenticationWindow?.rootViewController = UIHostingController(
            // [REQ:gemSpec_BSI_FdV:A_20834] mandatory app authentication
            rootView: AppAuthenticationView(store: appAuthenticationStore)
        )
        authenticationWindow?.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_: UIScene) {
        authenticationWindow = nil
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

extension SceneDelegate {
    private func environment() -> AppStartDomain.Environment {
        let schedulers = Schedulers()
        // TODO: load current selected profile and pass profileId // swiftlint:disable:this todo

        let erxTaskStore = ErxTaskCoreDataStore(
            profileId: nil,
            coreDataControllerFactory: coreDataControllerFactory
        )

        let sessionContainer = StandardSessionContainer(
            schedulers: schedulers,
            erxTaskCoreDataStore: erxTaskStore
        )
        let userSession = UserMode.standard(sessionContainer)
        let changeableUserSessionContainer = ChangeableUserSessionContainer(
            initialUserSession: userSession,
            schedulers: schedulers,
            erxTaskCoreDataStore: erxTaskStore
        )

        let tracker = PiwikProTracker(
            optOutSetting: UserDefaults.standard.publisher(for: \UserDefaults.kAppTrackingAllowed).eraseToAnyPublisher()
        )

        #if ENABLE_DEBUG_VIEW && targetEnvironment(simulator)
        // swiftlint:disable:next trailing_closure
        let signatureProvider = DefaultSecureEnclaveSignatureProvider(
            storage: changeableUserSessionContainer.userSession.secureUserStore,
            privateKeyContainerProvider: {
                try PrivateKeyContainer.createFromKeyChain(with: $0)
            }
        )
        #else
        let signatureProvider = DefaultSecureEnclaveSignatureProvider(
            storage: changeableUserSessionContainer.userSession.secureUserStore
        )
        #endif
        // This must be raw userDefaults access, demo session should *not* interfere with user authentication
        let standardUserDataStore = UserDefaultsStore(userDefaults: .standard)

        return .init(
            appVersion: AppVersion.current,
            router: self,
            userSessionContainer: changeableUserSessionContainer,
            userSession: changeableUserSessionContainer.userSession,
            // This must be raw userDefaults access, demo session should *not* interfere with user authentication
            userDataStore: standardUserDataStore,
            schedulers: schedulers,
            fhirDateFormatter: globals.fhirDateFormatter,
            serviceLocator: ServiceLocator(),
            accessibilityAnnouncementReceiver: { message in
                UIAccessibility.post(notification: .announcement,
                                     argument: message)
            },
            tracker: tracker,
            signatureProvider: signatureProvider,
            appSecurityManager: DefaultAppSecurityManager(keychainAccess: SystemKeychainAccessHelper()),
            authenticationChallengeProvider: BiometricsAuthenticationChallengeProvider()
        )
    }
}
