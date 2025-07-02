// swiftlint:disable file_length
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
import ComposableArchitecture
import eRpKit
import eRpStyleKit
import Perception
import SwiftUI

#if ENABLE_DEBUG_VIEW
// [REQ:BSI-eRp-ePA:O.Source_8#5] DebugView is only available on debug builds
struct DebugView: View {
    @Perception.Bindable var store: StoreOf<DebugDomain>

    var body: some View {
        WithPerceptionTracking {
            List {
                EnvironmentSection(store: store)
                LogSection(store: store)
                FeatureFlagsSection(store: store)
                VirtualEGKLogin(store: store)
                LocalTaskStatusView(store: store)
                CardWallSection(store: store)
                OnboardingSection(store: store)
                LoginSection(store: store)
            }
            .onAppear { store.send(.appear) }
            .alert(
                "Oh no!",
                isPresented: $store.showAlert,
                actions: { Button(L10n.alertBtnOk) {} },
                message: {
                    Text(store.alertText ?? "Unknown")
                }
            )
            .navigationTitle("Debug Settings")
        }
    }
}

extension DebugView {
    private struct OnboardingSection: View {
        @Perception.Bindable var store: StoreOf<DebugDomain>

        var body: some View {
            WithPerceptionTracking {
                Section(header: Text("Onboarding")) {
                    VStack {
                        Toggle("Hide Onboarding", isOn: $store.hideOnboarding)
                        FootnoteView(text: "Intro is only displayed once. Needs App restart.", a11y: "dummy_a11y_l")
                    }
                    Toggle("Tracking OptOut", isOn: $store.trackingOptIn)
                    Button("Reset tooltips") {
                        store.send(.resetTooltips)
                    }
                    Button("Reset AppDefaults") {
                        store.send(.resetAppDefaults)
                    }
                }
            }
        }
    }

    private struct CardWallSection: View {
        @Perception.Bindable var store: StoreOf<DebugDomain>

        var body: some View {
            WithPerceptionTracking {
                Section(header: Text("Cardwall")) {
                    VStack {
                        Toggle("Hide Intro", isOn: $store.hideCardWallIntro)
                            .accessibilityIdentifier("debug_tog_hide_intro")

                        FootnoteView(
                            text: "CardWall Intro is only displayed until accepted once.",
                            a11y: "dummy_a11y_e"
                        )
                        .font(.subheadline)
                    }
                    Toggle("Fake Device Capabilities", isOn: $store.useDebugDeviceCapabilities.animation())
                    if store.useDebugDeviceCapabilities {
                        VStack {
                            Toggle("NFC ready", isOn: $store.isNFCReady)
                            Toggle("iOS 14", isOn: $store.isMinimumOS14)
                        }
                        .padding(.leading, 16)
                    }
                    Button("Reset CAN") {
                        store.send(.resetCanButtonTapped)
                    }
                    Button("Reset Biometrie (Key and Cert)") {
                        store.send(.deleteKeyAndEGKAuthCertForBiometric)
                    }
                    Button("Reset CERT- and OCSP-Lists") {
                        store.send(.resetOcspAndCertListButtonTapped)
                    }
                }
            }
        }
    }

    struct LocalTaskStatusView: View {
        @Perception.Bindable var store: StoreOf<DebugDomain>

        var body: some View {
            WithPerceptionTracking {
                Section(header: Text("Prescriptions")) {
                    VStack(alignment: .leading) {
                        Text("Fake prescription status for:")
                        HStack {
                            TextField("Test", text: $store.fakeTaskStatus)
                                .keyboardType(.numberPad)
                            Text("Seconds")
                                .foregroundColor(.gray)
                        }
                        .font(.system(.body, design: .monospaced))
                    }
                    HStack {
                        Text("Mark Messages as read")
                        Spacer()
                        Button("Mark") {
                            store.send(.markCommunicationsAsRead)
                        }
                    }
                    HStack {
                        Text("Local tasks: \($store.localTasks.count)")
                        Spacer()
                        Button("Delete") {
                            store.send(.deleteAllTasks)
                        }
                    }
                }
            }
        }
    }

    struct VirtualEGKLogin: View {
        @Perception.Bindable var store: StoreOf<DebugDomain>

        @State var showScanVirtualEGK = false

        var body: some View {
            WithPerceptionTracking {
                Section(
                    header: Text("Virtual eGK Login"),
                    footer: Text("""
                    When enabled, the provided key and certificate is used instead of your NFC eGK.
                    Just go threw the regular 'Anmelden' screens. The entered CAN and PIN will be ignored.
                    """)
                ) {
                    Toggle("Use Virtual eGK instead of NFC", isOn: $store.useVirtualLogin.animation())
                        .accessibilityIdentifier("debug_enable_virtual_egk")

                    if store.useVirtualLogin {
                        NavigationLink(
                            destination: DebugEGKScannerView(
                                show: $showScanVirtualEGK,
                                prkCHAUTbase64: $store.virtualLoginPrivateKey,
                                cCHAUTbase64: $store.virtualLoginCertKey
                            ),
                            isActive: $showScanVirtualEGK
                        ) {
                            HStack {
                                Text("Scan virtual eGK")
                                Image(systemName: SFSymbolName.qrCode)
                            }
                        }

                        VStack {
                            TextEditor(text: $store.virtualLoginPrivateKey)
                                .accessibility(identifier: "debug_prk_ch_aut")
                                .frame(minHeight: 100, maxHeight: 100)
                                .foregroundColor(Colors.systemLabel)
                                .border(Colors.separator)
                                .keyboardType(.default)
                                .disableAutocorrection(true)

                            FootnoteView(text: "Private Key as BASE64 (PrK_CH_AUT)", a11y: "dummy_a11y_i")
                        }

                        VStack {
                            TextEditor(text: $store.virtualLoginCertKey)
                                .accessibility(identifier: "debug_c_ch_aut")
                                .frame(minHeight: 100, maxHeight: 100)
                                .foregroundColor(Colors.systemLabel)
                                .keyboardType(.default)
                                .border(Colors.separator)
                                .disableAutocorrection(true)

                            FootnoteView(text: "DER Certificate as BASE64 (C.CH.AUT)", a11y: "dummy_a11y_i")
                        }
                    }
                }
            }
        }
    }

    private struct LoginSection: View {
        @Dependency(\.fhirDateFormatter) var dateFormatter: FHIRDateFormatter
        @Perception.Bindable var store: StoreOf<DebugDomain>

        var hidePkvConsentDrawerOnMainView: Binding<Bool> { Binding(
            get: {
                store.hidePkvConsentDrawerOnMainView
            }, set: { _ in
                store.send(.hidePkvConsentDrawerMainViewToggleTapped)
            }
        ) }

        var body: some View {
            WithPerceptionTracking {
                Section(content: {
                    if let profile = store.profile {
                        HStack {
                            ProfilePictureView(image: .baby,
                                               userImageData: nil,
                                               color: .red,
                                               connection: nil,
                                               style: .small) {}

                            VStack(alignment: .leading) {
                                Text(profile.name)
                                Text("\nInsurance Type: \(profile.insuranceType.rawValue)")
                                    .font(.footnote)
                            }
                        }

                        Button("Mark as PKV") {
                            store.send(.setProfileInsuranceTypeToPKV)
                        }
                        //                        .disabled(profile.insuranceType != .gKV)
                        .foregroundColor(profile.insuranceType == .gKV ? Color.orange : Color.gray)
                        .accessibilityIdentifier("debug_btn_mark_profile_as_pkv")

                        FootnoteView(
                            text: "Profiles that have been logged in may be marked as pKV profiles. Marked profiles may not be converted back.",
                            // swiftlint:disable:previous line_length
                            a11y: ""
                        )

                        VStack {
                            Toggle("Hide ConsentDrawer On MainScreen", isOn: hidePkvConsentDrawerOnMainView)
                            FootnoteView(
                                text: "Drawer will only be shown when consent is currently not granted",
                                a11y: "dummy_a11y_k"
                            )
                        }
                    } else {
                        Text("Loading current Profile...")
                    }
                }, header: { Text("Active Profile") })

                Section(content: {
                    Group {
                        TextEditor(text: $store.accessCodeText)
                            .accessibilityIdentifier("debug_txt_access_token_write")
                            .frame(minHeight: 100, maxHeight: 150)
                            .foregroundColor(Colors.systemLabel)
                            .border(Colors.separator)
                            .keyboardType(.default)
                            .disableAutocorrection(true)
                        FootnoteView(
                            text: "Initial access token can only be used for gematik IDP. Token will be updated to the latest used token after using logout here",
                            // swiftlint:disable:previous line_length
                            a11y: ""
                        )
                    }

                    HStack {
                        Text("Logged in:")
                        if store.isAuthenticated ?? false {
                            Text("YES").bold().foregroundColor(.green)
                            Spacer()
                            Button("Logout") {
                                store.send(.logoutButtonTapped)
                            }
                            .foregroundColor(.red)
                        } else {
                            Text("NO").bold().foregroundColor(.red)
                            Spacer()
                            Button("Login") {
                                withAnimation {
                                    UIApplication.shared.dismissKeyboard()
                                    store.send(.loginWithToken)
                                }
                            }
                            .foregroundColor(.green)
                        }
                    }

                    FootnoteView(
                        text: "This Login will use the provided access-token and ignore any setting of the Virtual eGK Section",
                        // swiftlint:disable:previous line_length
                        a11y: ""
                    )

                    SectionHeaderView(text: "Current access-token", a11y: "dummy_a11y_i")
                    Text(store.token?.accessToken ?? "*** No valid token available ***")
                        .contextMenu(ContextMenu {
                            Button("Copy") {
                                UIPasteboard.general.string = store.token?.accessToken
                            }
                        })
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: 100)
                        .foregroundColor(Colors.systemGray)
                        .background(Color(.systemGray5))
                        .accessibilityIdentifier("debug_txt_access_token_read")
                    if let date = store.token?.expires {
                        let expires = dateFormatter.string(from: date)
                        FootnoteView(
                            text: "Access-token is valid until \(expires). Token can be copied with long touch.",
                            a11y: "dummy_a11y_i"
                        )
                    } else {
                        FootnoteView(text: "No valid access-token available", a11y: "dummy_a11y_i")
                    }
                    Button("Invalidate current access-token (which enforces using SSO-Token)") {
                        store.send(.invalidateAccessToken)
                    }
                    Button("Falsify current SSO-Token and invalidate current access-token") {
                        store.send(.falsifySSOToken)
                    }
                    Button("Delete SSO-Token and invalidate current access-token") {
                        store.send(.deleteSSOToken)
                    }
                }, header: { Text("Login With Token") })
            }
        }
    }

    private struct LogSection: View {
        @Perception.Bindable var store: StoreOf<DebugDomain>

        #if DEBUG
        @Dependency(\.smartMockRegister) var smartMockRegister: SmartMockRegister
        #endif

        var body: some View {
            Section(content: {
                WithPerceptionTracking {
                    NavigationLink("Logs", destination: DebugLogsView(
                        store: store.scope(state: \.logState, action: \.logAction)
                    ))
                }

                #if DEBUG
                Button {
                    try? smartMockRegister.save()
                } label: {
                    SubTitle(title: "Save SmartMocks", description: "& copy mocks path to clipboard")
                }
                #endif
            }, header: { Text("Logging") })
        }
    }

    private struct TechDetail: View {
        let text: LocalizedStringKey
        let value: String

        init(_ text: LocalizedStringKey, value: String) {
            self.text = text
            self.value = value
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(text, bundle: .module)
                Text(value).font(.system(.footnote, design: .monospaced))
            }.contextMenu {
                Button(
                    action: {
                        UIPasteboard.general.string = value
                    }, label: {
                        Label(L10n.dtlBtnCopyClipboard,
                              systemImage: SFSymbolName.copy)
                    }
                )
            }
        }
    }

    private struct EnvironmentSection: View {
        @Perception.Bindable var store: StoreOf<DebugDomain>

        var body: some View {
            WithPerceptionTracking {
                let environmentName = store.selectedEnvironment?.name ?? "TU"
                Section(content: {
                    Picker("Environment", selection: Binding(
                        get: {
                            environmentName
                        }, set: { newValue in
                            store.send(.setServerEnvironment(newValue))
                        }
                    )) {
                        ForEach(store.availableEnvironments, id: \.id) { serverEnvironment in
                            Text(serverEnvironment.configuration.name).tag(serverEnvironment.name)
                        }
                    }

                    if let environment = store.selectedEnvironment?.configuration {
                        HStack {
                            Text("Current")
                            Spacer()
                            Text(environment.name)
                        }
                        DebugView.TechDetail("IDP", value: environment.idp.absoluteString)
                        DebugView.TechDetail("FD", value: environment.erp.absoluteString)
                        DebugView.TechDetail("FHIR VZD", value: environment.fhirVzd.absoluteString)
                        DebugView.TechDetail("eRezept API", value: environment.eRezept.absoluteString)
                    }

                    Button("Reset") {
                        store.send(DebugDomain.Action.setServerEnvironment(nil))
                    }
                }, header: { Text("Environment") })
            }
        }
    }

    private struct FeatureFlagsSection: View {
        @Perception.Bindable var store: StoreOf<DebugDomain>

        var body: some View {
            Section(content: {
                NavigationLink(destination: FeatureFlags(store: store)) {
                    Text("Feature Flags")
                }
            }, header: { Text("Feature Flags") })
        }

        private struct FeatureFlags: View {
            @Perception.Bindable var store: StoreOf<DebugDomain>

            var body: some View {
                WithPerceptionTracking {
                    List {
                        Section {
                            TextField(
                                "Overwrite DIGA IK (e.g. 101570104)",
                                text: $store.overwriteDIGAIK
                            )
                        } header: {
                            Text("DIGA")
                        } footer: {
                            HStack {
                                Button {
                                    store.$overwriteDIGAIK.withLock { $0 = "101570104" }
                                } label: {
                                    Text("Set to 101570104")
                                }
                                Button {
                                    store.$overwriteDIGAIK.withLock { $0 = "" }
                                } label: {
                                    Text("Reset")
                                }
                            }
                        }
                        Section {
                            Toggle("Show Debug Pharmacies", isOn: $store.showDebugPharmacies)
                            Text(
                                "Displays under 'Debug Pharmacies' stored pharmacies in the pharmacy search"
                            )
                            .font(.footnote)
                            NavigationLink(destination: AVSDebugView()) {
                                Text("Debug Pharmacies")
                            }.disabled(!store.showDebugPharmacies)
                        }
                    }
                }
            }
        }
    }
}

extension SharedReaderKey
    where Self == AppStorageKey<Bool>.Default {
    static var showDebugPharmacies: Self {
        Self[.appStorage("show_debug_pharmacies"), default: false]
    }
}

extension SharedReaderKey
    where Self == AppStorageKey<String>.Default {
    static var overwriteDIGAIK: Self {
        Self[.appStorage("overwriteDIGAIK"), default: ""]
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DebugView(store: DebugDomain.Dummies.store)
        }
        .previewDevice("iPhone SE (2nd generation)")
    }
}

#endif

// swiftlint:enable file_length
