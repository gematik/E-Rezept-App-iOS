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
import IDP
import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, Routing {
    var mainWindow,
        authenticationWindow: UIWindow?

    var routerStore: RouterStore<AppDomain.State, AppDomain.Action, AppDomain.Environment>?

    func scene(_ scene: UIScene,
               willConnectTo _: UISceneSession,
               options _: UIScene.ConnectionOptions) {
        // As soon as AppContainer is removed, the construction of ChangeableUserSessionContainer will be here
        let sessionContainer = AppContainer.shared.userSessionContainer

        let tracker = PiwikProTracker(
            optOutSetting: UserDefaults.standard.publisher(for: \UserDefaults.kAppTrackingAllowed).eraseToAnyPublisher()
        )

        let signatureProvider = DefaultSecureEnclaveSignatureProvider(
            storage: sessionContainer.userSession.secureUserStore
        )

        let routableAppStore = RouterStore(
            initialState: AppDomain.State(
                selectedTab: .main,
                onboarding: nil,
                appAuthentication: nil,
                main: MainDomain.State(
                    prescriptionListState: GroupedPrescriptionListDomain.State(),
                    debug: DebugDomain.State(trackingOptOut: tracker.optOut)
                ),
                messages: MessagesDomain.State(messageDomainStates: []),
                unreadMessagesCount: 0,
                isDemoMode: false
            ),
            reducer: AppDomain.reducer,
            environment: AppDomain.Environment(
                router: self,
                userSessionContainer: sessionContainer,
                userSession: sessionContainer.userSession,
                schedulers: Schedulers(),
                fhirDateFormatter: AppContainer.shared.fhirDateFormatter,
                serviceLocator: AppContainer.shared.serviceLocator,
                accessibilityAnnouncementReceiver: { message in
                    UIAccessibility.post(notification: .announcement,
                                         argument: message)
                },
                tracker: tracker,
                signatureProvider: signatureProvider
            ),
            router: AppDomain.router
        )

        routerStore = routableAppStore

        if let windowScene = scene as? UIWindowScene {
            authenticationWindow = UIWindow(windowScene: windowScene)
            mainWindow = UIWindow(windowScene: windowScene)
            mainWindow?.rootViewController = UIHostingController(
                rootView: TabContainerView(
                    store: routableAppStore.wrappedStore
                )
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
        let userDataStore = AppContainer
            .shared
            .userSessionContainer
            .userSession
            .localUserStore

        authenticationWindow?.rootViewController = UIHostingController(
            rootView: AppAuthenticationView(
                store: AppAuthenticationDomain.Store(
                    initialState: AppAuthenticationDomain.State(),
                    reducer: AppAuthenticationDomain.reducer,
                    environment: AppAuthenticationDomain.Environment(
                        userDataStore: userDataStore,
                        schedulers: Schedulers(),
                        appAuthenticationProvider:
                            AppAuthenticationDomain.DefaultAuthenticationProvider(
                                userDataStore: userDataStore
                            )
                    ) { [weak self] in
                        self?.mainWindow?.accessibilityElementsHidden = false
                        self?.mainWindow?.makeKeyAndVisible()
                        self?.mainWindow?.backgroundColor = UIColor.black
                    }
                )
            )
        )
        mainWindow?.accessibilityElementsHidden = true
        authenticationWindow?.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_: UIScene) {
        addBlurOverlayToWindow()
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
