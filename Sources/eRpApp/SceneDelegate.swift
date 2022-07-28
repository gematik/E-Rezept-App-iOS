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
    private let coreDataControllerFactory: CoreDataControllerFactory = LocalStoreFactory()
    // This must be raw userDefaults access, demo session should *not* interfere with user authentication
    private let userDataStore = UserDefaultsStore(userDefaults: .standard)
    private lazy var routerStore = RouterStore(
        initialState: .init(),
        reducer: AppStartDomain.reducer.notifyUserInteraction(),
        environment: environment(),
        router: AppStartDomain.router
    )

    private lazy var migrationCoordinator = MigrationCoordinator(userDataStore: userDataStore)

    // Timer that counts down until the app will be locked
    var appLockTimer: Timer?

    private struct MigrationCoordinator {
        let userDataStore: UserDataStore
        var isMigrating = false

        var shouldMigrateDatabase: Bool {
            userDataStore.isOnboardingHidden && !userDataStore.latestCompatibleModelVersion.isLastVersion
        }

        func set(latestCompatibleModel version: ModelVersion) {
            userDataStore.latestCompatibleModelVersion = version
        }
    }

    func scene(_ scene: UIScene,
               willConnectTo _: UISceneSession,
               options _: UIScene.ConnectionOptions) {
        userDataStore.appStartCounter += 1

        if let windowScene = scene as? UIWindowScene {
            mainWindow = UIWindow(windowScene: windowScene)
        }

        if migrationCoordinator.shouldMigrateDatabase {
            migrationCoordinator.isMigrating = true
            presentAppMigrationDomain { [weak self, weak scene] in
                guard let self = self else { return }
                self.migrationCoordinator.isMigrating = false
                self.mainWindow?.rootViewController = UIHostingController(
                    rootView: AppStartView(store: self.routerStore.wrappedStore)
                )
                self.mainWindow?.makeKeyAndVisible()
                self.presentAppAuthenticationDomain(scene: scene)
                self.setupNotifications(scene: scene)
            }
        } else {
            migrationCoordinator.set(latestCompatibleModel: .latestVersion)
            mainWindow?.rootViewController = UIHostingController(
                rootView: AppStartView(store: routerStore.wrappedStore)
            )
            mainWindow?.makeKeyAndVisible()
            setupNotifications(scene: scene)
        }
    }

    func routeTo(_ endpoint: Endpoint) {
        routerStore.route(to: endpoint)
    }

    func sceneDidDisconnect(_: UIScene) {}

    func sceneDidBecomeActive(_: UIScene) {}

    func sceneWillResignActive(_: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {
        removeBlurOverlayFromWindow()

        guard !migrationCoordinator.isMigrating else { return }

        presentAppAuthenticationDomain(scene: scene)
    }

    func presentAppMigrationDomain(completion: @escaping () -> Void) {
        let migrationManager = MigrationManager(
            factory: coreDataControllerFactory,
            erxTaskCoreDataStore: ErxTaskCoreDataStore(
                profileId: nil,
                coreDataControllerFactory: coreDataControllerFactory
            ),
            userDataStore: userDataStore
        )
        let migrationStore = Store(
            initialState: AppMigrationDomain.State.none,
            reducer: AppMigrationDomain.reducer,
            environment: AppMigrationDomain.Environment(
                schedulers: Schedulers(),
                migrationManager: migrationManager,
                factory: coreDataControllerFactory,
                userDataStore: userDataStore,
                fileManager: FileManager.default,
                finishedMigration: completion
            )
        )

        mainWindow?.rootViewController = UIHostingController(
            rootView: AppMigrationView(store: migrationStore)
        )
        mainWindow?.makeKeyAndVisible()
    }

    func presentAppAuthenticationDomain(scene: UIScene?) {
        guard let windowScene = scene as? UIWindowScene else {
            // prevent using the app if authentication view can't be presented
            mainWindow?.rootViewController = nil
            return
        }
        invalidateTimer()

        let authenticationProvider = AppAuthenticationDomain.DefaultAuthenticationProvider(
            userDataStore: userDataStore
        )
        let appAuthenticationStore = Store(
            initialState: AppAuthenticationDomain.State(),
            reducer: AppAuthenticationDomain.reducer,
            environment: AppAuthenticationDomain.Environment(
                userDataStore: userDataStore,
                schedulers: Schedulers(),
                appAuthenticationProvider: authenticationProvider,
                appSecurityPasswordManager: DefaultAppSecurityManager(keychainAccess: SystemKeychainAccessHelper()),
                authenticationChallengeProvider: BiometricsAuthenticationChallengeProvider()
            ) { [weak self, weak scene] in
                guard let self = self else { return }
                self.mainWindow?.accessibilityElementsHidden = false
                self.mainWindow?.makeKeyAndVisible()
                // background color is lost after window switch, reset it to black
                self.mainWindow?.backgroundColor = UIColor.black
                self.authenticationWindow?.rootViewController = nil
                self.authenticationWindow = nil
                self.setupNotifications(scene: scene)
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

import Combine

extension SceneDelegate {
    private func sessionContainer(
        with schedulers: Schedulers
    ) -> (ChangeableUserSessionContainer, UserSessionProvider) {
        let profileCoreDataStore = ProfileCoreDataStore(coreDataControllerFactory: coreDataControllerFactory)

        // On app install, no profile is created yet, create a session with a random UUID. This UUID is reused upon
        // onboarding completion, to create the actual profile. Both IDs MUST match. Mabe FIXME by creating an empty
        // profile, that is updated upon onboarding completion. // swiftlint:disable:previous todo
        let initialProfileId = UUID(
            uuidString: UserDefaults.standard.string(forKey: UserDefaults.kSelectedProfileId) ?? ""
        ) ?? UUID()

        let initialUserSession = StandardSessionContainer(
            for: initialProfileId,
            schedulers: schedulers,
            erxTaskCoreDataStore: ErxTaskCoreDataStore(
                profileId: initialProfileId,
                coreDataControllerFactory: coreDataControllerFactory
            ),
            profileDataStore: profileCoreDataStore,
            shipmentInfoDataStore: ShipmentInfoCoreDataStore(coreDataControllerFactory: coreDataControllerFactory),
            avsTransactionDataStore: AVSTransactionCoreDataStore(coreDataControllerFactory: coreDataControllerFactory),
            appConfiguration: userDataStore.appConfiguration
        )

        let userSessionProvider = DefaultUserSessionProvider(
            initialUserSession: initialUserSession,
            schedulers: schedulers,
            coreDataControllerFactory: coreDataControllerFactory,
            profileDataStore: profileCoreDataStore,
            appConfiguration: userDataStore.appConfiguration
        )

        let changeableUserSessionContainer = ChangeableUserSessionContainer(
            initialUserSession: initialUserSession,
            userDataStore: userDataStore,
            userSessionProvider: userSessionProvider
        )

        return (changeableUserSessionContainer, userSessionProvider)
    }

    private func environment() -> AppStartDomain.Environment {
        let schedulers = Schedulers()
        let (changeableUserSessionContainer, userSessionProvider) = sessionContainer(with: schedulers)

        let tracker = PlaceholderTracker() // TODO: replace with new tracker //swiftlint:disable:this todo

        #if ENABLE_DEBUG_VIEW && targetEnvironment(simulator)
        // swiftlint:disable:next trailing_closure
        let signatureProvider = DefaultSecureEnclaveSignatureProvider(
            storage: changeableUserSessionContainer.userSession.secureUserStore,
            privateKeyContainerProvider: { try PrivateKeyContainer.createFromKeyChain(with: $0) }
        )
        #else
        let signatureProvider = DefaultSecureEnclaveSignatureProvider(
            storage: changeableUserSessionContainer.userSession.secureUserStore
        )
        #endif

        return .init(
            appVersion: AppVersion.current,
            router: self,
            userSessionContainer: changeableUserSessionContainer,
            userSession: changeableUserSessionContainer.userSession,
            // This must be raw userDefaults access, demo session should *not* interfere with user authentication
            userDataStore: userDataStore,
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
            authenticationChallengeProvider: BiometricsAuthenticationChallengeProvider(),
            userSessionProvider: userSessionProvider
        )
    }
}

extension SceneDelegate {
    func setupNotifications(scene: UIScene?) {
        setupTimer(scene: scene)

        NotificationCenter.default.addObserver(
            forName: .userInteractionDetected,
            object: nil,
            queue: OperationQueue.main
        ) { [weak self, weak scene] _ in
            self?.setupTimer(scene: scene)
        }
    }

    func invalidateTimer() {
        appLockTimer?.invalidate()
        appLockTimer = nil
    }

    func setupTimer(scene: UIScene?) {
        invalidateTimer()

        appLockTimer = Timer.scheduledTimer(
            withTimeInterval: 60 * 10,
            repeats: false
        ) { [weak self, weak scene] timer in
            timer.invalidate()

            self?.presentAppAuthenticationDomain(scene: scene)
        }
    }
}

extension Reducer where Action: Equatable {
    fileprivate func notifyUserInteraction( // swiftlint:disable:this strict_fileprivate
    ) -> Reducer<State, Action, Environment> {
        .init { state, action, environment in
            NotificationCenter.default.post(name: .userInteractionDetected, object: nil, userInfo: nil)

            return self.run(&state, action, environment)
        }
    }
}

extension Notification.Name {
    static let userInteractionDetected = Self(rawValue: "USER_INTERACTION_DETECTED")
}
