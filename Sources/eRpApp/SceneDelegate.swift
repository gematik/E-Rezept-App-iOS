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

import ComposableArchitecture
import ContentsquareModule
import eRpKit
import eRpLocalStorage
import IDP
import SwiftUI
import UIKit

extension View {
    func prepareUITestsEnvironment() -> some View {
        #if DEBUG
        setupUITests()
        #else
        self
        #endif
    }
}

extension Reducer {
    func prepareUITestsDependencies() -> some Reducer<Self.State, Self.Action> {
        #if DEBUG
        setupUITests()
        #else
        self
        #endif
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate, Routing {
    var mainWindow: UIWindow?
    var authenticationWindow: UIWindow?
    lazy var notificationDelegate = LocalNotificationDelegate(router: self.routerStore)

    // This must be raw userDefaults access, demo session should *not* interfere with user authentication
    @Dependency(\.userDataStore) var userDataStore
    @Dependency(\.tracker) var tracker
    @Dependency(\.profileCoreDataStore) var profileCoreDataStore

    lazy var routerStore: RouterStore<some Reducer<AppStartDomain.State, AppStartDomain.Action>> =
        RouterStore(
            initialState: .init(),
            // [REQ:BSI-eRp-ePA:O.Auth_9#5] Concat the user interaction reducer to the normal application reducer
            reducer: AppStartDomain().analytics().notifyUserInteraction().prepareUITestsDependencies(),
            router: AppStartDomain.router
        )

    private lazy var migrationCoordinator = MigrationCoordinator(userDataStore: userDataStore)

    // Timer that counts down until the app will be locked
    var appLockTimer: Timer?

    // For delaying the universal link after the authentication dialog has been shown.
    var universalLinkAfterAuthentication: URL?

    // For delaying the universal link after the authentication dialog has been shown.
    var willPresentAppAuthenticationDialog = false

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

    func parseUserActivities(_ activities: Set<NSUserActivity>) {
        for userActivity in activities {
            switch userActivity.activityType {
            case NSUserActivityTypeBrowsingWeb:
                guard let url = userActivity.webpageURL else { return }
                universalLinkAfterAuthentication = url
            default:
                break
            }
        }
    }

    func scene(_ scene: UIScene,
               willConnectTo _: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        #if targetEnvironment(simulator)
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return
        }
        #endif
        userDataStore.appStartCounter += 1

        if let windowScene = scene as? UIWindowScene {
            mainWindow = UIWindow(windowScene: windowScene)
        }
        parseUserActivities(connectionOptions.userActivities)

        UITextField.appearance().clearButtonMode = .whileEditing

        UNUserNotificationCenter.current().delegate = notificationDelegate

        #if DEBUG
        setupUITests()
        #endif

        do {
            // If necessary, migrate app security
            @Dependency(\.appSecurityManager) var appSecurityManager
            try appSecurityManager.migrate()

            try sanitizeDatabases(store: profileCoreDataStore)
        } catch {
            assertionFailure(error.localizedDescription)
        }

        if migrationCoordinator.shouldMigrateDatabase {
            migrationCoordinator.isMigrating = true
            presentAppMigrationDomain { [weak self, weak scene] in
                guard let self = self else { return }
                self.migrationCoordinator.isMigrating = false
                self.mainWindow?.rootViewController = UIHostingController(
                    rootView: AppStartView(store: self.routerStore.wrappedStore).prepareUITestsEnvironment()
                )
                self.mainWindow?.makeKeyAndVisible()
                self.presentAppAuthenticationDomain(scene: scene)
                self.setupNotifications(scene: scene)
            }
        } else {
            migrationCoordinator.set(latestCompatibleModel: .latestVersion)
            mainWindow?.rootViewController = UIHostingController(
                rootView: AppStartView(store: routerStore.wrappedStore)
                    .prepareUITestsEnvironment()
            )
            mainWindow?.makeKeyAndVisible()
            setupNotifications(scene: scene)
        }

        #if ENABLE_DEBUG_VIEW
        if let url = connectionOptions.urlContexts.first?.url {
            Contentsquare.handle(url: url)
        }
        #endif
    }

    func routeTo(_ endpoint: Endpoint) {
        routerStore.routeTo(endpoint)
    }

    func sceneDidDisconnect(_: UIScene) {}

    func sceneDidBecomeActive(_: UIScene) {}

    func sceneWillResignActive(_: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {
        #if targetEnvironment(simulator)
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return
        }
        #endif

        // [REQ:BSI-eRp-ePA:O.Data_13#3,O.Plat_9#3] Moving the application to the foreground removes the blur.
        removeBlurOverlayFromWindow()

        #if DEBUG
        if ProcessInfo.processInfo.environment["UITEST.DISABLE_AUTHENTICATION"] == "YES" {
            return
        }
        #endif

        guard !migrationCoordinator.isMigrating else { return }

        willPresentAppAuthenticationDialog = true
        // [REQ:BSI-eRp-ePA:O.Auth_8#2] Present the authentication window
        // [REQ:gemSpec_eRp_FdV:A_24857#2] Present the authentication window upon every startup
        // dispatching necessary to prevents keyboard not showing on iOS 16
        DispatchQueue.main.async { [weak self] in
            self?.presentAppAuthenticationDomain(scene: scene)
        }
    }

    func presentAppMigrationDomain(completion: @escaping () -> Void) {
        let migrationStore = Store(
            initialState: .init(migration: .none)
        ) {
            AppMigrationDomain(
                fileManager: FileManager.default,
                finishedMigration: completion
            )
        }

        mainWindow?.rootViewController = UIHostingController(
            rootView: AppMigrationView(store: migrationStore)
        )
        mainWindow?.makeKeyAndVisible()
    }

    func presentAppAuthenticationDomain(scene: UIScene?) {
        willPresentAppAuthenticationDialog = false

        guard let windowScene = scene as? UIWindowScene else {
            // prevent using the app if authentication view can't be presented
            mainWindow?.rootViewController = nil
            return
        }
        invalidateTimer()

        let appAuthenticationStore = Store(
            initialState: AppAuthenticationDomain.State()
        ) {
            AppAuthenticationDomain { [weak self, weak scene] in
                guard let self = self else { return }
                self.mainWindow?.accessibilityElementsHidden = false
                self.mainWindow?.makeKeyAndVisible()
                // background color is lost after window switch, reset it to black
                self.mainWindow?.backgroundColor = UIColor.black
                self.authenticationWindow?.rootViewController = nil
                self.authenticationWindow = nil
                self.setupNotifications(scene: scene)

                // Fire delayed universal links after timeout, to allow transitions to complete
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    if let url = self.universalLinkAfterAuthentication {
                        // [REQ:gemSpec_IDP_Frontend:A_22301-01#2] If app needs reauthentication routing starts here.
                        self.routeTo(.universalLink(url))
                    }
                    self.universalLinkAfterAuthentication = nil
                }
            }
        }

        mainWindow?.accessibilityElementsHidden = true
        authenticationWindow = UIWindow(windowScene: windowScene)
        authenticationWindow?.rootViewController = UIHostingController(
            rootView: AppAuthenticationView(store: appAuthenticationStore)
        )
        authenticationWindow?.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_: UIScene) {
        authenticationWindow = nil
        // [REQ:BSI-eRp-ePA:O.Data_13#2,O.Plat_9#2] Moving the application to the background blurs the application
        // window.
        addBlurOverlayToWindow()
    }

    // [REQ:BSI-eRp-ePA:O.Source_1#5] External application calls via Universal Linking
    func scene(_: UIScene, continue userActivity: NSUserActivity) {
        switch userActivity.activityType {
        case NSUserActivityTypeBrowsingWeb:
            guard let url = userActivity.webpageURL else { return }
            // Delay calls if authentication is about to be shown. In that case authentication will handle calling the
            // universal link
            if willPresentAppAuthenticationDialog {
                universalLinkAfterAuthentication = url
            } else {
                // [REQ:gemSpec_IDP_Frontend:A_22301-01#3] If app is already started, routing starts here.
                routeTo(.universalLink(url))
            }
        default:
            break
        }
    }

    #if ENABLE_DEBUG_VIEW
    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            Contentsquare.handle(url: url)
        }
    }
    #endif

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
    // The app needs at least one `Profile` in order to function correctly. If there is no Profile we assume
    // that the app is in the initial state for which also the `UserDataStore` should be in initial state
    func sanitizeDatabases(store: ProfileCoreDataStore) throws {
        let hasProfile = (try? store.hasProfile()) ?? false
        if !hasProfile {
            userDataStore.set(hideOnboarding: false)
            // [REQ:gemSpec_eRp_FdV:A_19090-01] activate after optIn is granted
            tracker.stopTracking()

            let profile = try store.createProfile(with: L10n.onbProfileName.text)
            userDataStore.set(selectedProfileId: profile.id)
        }
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
            // [REQ:BSI-eRp-ePA:O.Auth_9#3] The timer is reset on user interaction
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

            // [REQ:BSI-eRp-ePA:O.Auth_9#2] The timer used to determine inactivity
            self?.presentAppAuthenticationDomain(scene: scene)
        }
    }
}

extension Reducer where Action: Equatable {
    func notifyUserInteraction() -> some Reducer<Self.State, Self.Action> {
        Reduce { state, action in
            // [REQ:BSI-eRp-ePA:O.Auth_9#4] User interaction is determined by using a higher order reducer watching all
            // actions
            NotificationCenter.default.post(name: .userInteractionDetected, object: nil, userInfo: nil)

            return self.reduce(into: &state, action: action)
        }
    }
}

extension Notification.Name {
    static let userInteractionDetected = Self(rawValue: "USER_INTERACTION_DETECTED")
}
