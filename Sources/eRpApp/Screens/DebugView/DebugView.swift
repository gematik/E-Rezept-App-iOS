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

import Combine
import ComposableArchitecture
import eRpKit
import SwiftUI

#if ENABLE_DEBUG_VIEW

struct DebugView: View {
    let store: DebugDomain.Store

    var body: some View {
        WithViewStore(store) { viewStore in
            List {
                EnvironmentSection(store: store)
                LogSection(store: store)
                FeatureFlagsSection()
                VirtualEGKLogin(store: store)
                LocalTaskStatusView(store: store)
                CardWallSection(store: store)
                OnboardingSection(store: store)
                LoginSection(store: store)
            }
            .onAppear { viewStore.send(.appear) }
            .alert(isPresented: viewStore.binding(
                get: \.showAlert,
                send: DebugDomain.Action.showAlert
            )) {
                Alert(title: Text("Oh no!"),
                      message: Text(viewStore.alertText ?? "Unknown"),
                      dismissButton: .default(Text("Ok")))
            }
        }.navigationTitle("Debug Settings")
    }
}

extension DebugView {
    private struct OnboardingSection: View {
        let store: DebugDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                Section(header: Text("Onboarding")) {
                    VStack {
                        Toggle("Hide Onboarding", isOn: viewStore.binding(
                            get: \.hideOnboarding,
                            send: DebugDomain.Action.hideOnboardingToggleTapped
                        ))
                        FootnoteView(text: "Intro is only displayed once. Needs App restart.", a11y: "dummy_a11y_l")
                    }
                    Toggle("Tracking OptOut",
                           isOn: viewStore.binding(
                               get: { state in state.trackingOptIn },
                               send: DebugDomain.Action.toggleTrackingTapped
                           ))
                    Button("Reset tooltips") {
                        viewStore.send(.resetTooltips)
                    }
                }
            }
        }
    }

    private struct CardWallSection: View {
        let store: DebugDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                Section(header: Text("Cardwall")) {
                    VStack {
                        Toggle("Hide Intro",
                               isOn: viewStore.binding(
                                   get: \.hideCardWallIntro,
                                   send: DebugDomain.Action.hideCardWallIntroToggleTapped
                               ))
                            .accessibilityIdentifier("debug_tog_hide_intro")

                        FootnoteView(
                            text: "CardWall Intro is only displayed until accepted once.",
                            a11y: "dummy_a11y_e"
                        )
                        .font(.subheadline)
                    }
                    Toggle("Fake Device Capabilities",
                           isOn: viewStore.binding(
                               get: \.useDebugDeviceCapabilities,
                               send: DebugDomain.Action.useDebugDeviceCapabilitiesToggleTapped
                           )
                           .animation())
                    if viewStore.useDebugDeviceCapabilities {
                        VStack {
                            Toggle("NFC ready", isOn: viewStore.binding(
                                get: \.isNFCReady,
                                send: DebugDomain.Action.nfcReadyToggleTapped
                            ))
                            Toggle("iOS 14", isOn: viewStore.binding(
                                get: \.isMinimumOS14,
                                send: DebugDomain.Action.isMinimumOS14ToggleTapped
                            ))
                        }
                        .padding(.leading, 16)
                    }
                    Button("Reset CAN") {
                        viewStore.send(.resetCanButtonTapped)
                    }
                    Button("Reset Biometrie (Key and Cert)") {
                        viewStore.send(.deleteKeyAndEGKAuthCertForBiometric)
                    }
                    Button("Reset CERT- and OCSP-Lists") {
                        viewStore.send(.resetOcspAndCertListButtonTapped)
                    }
                }
            }
        }
    }

    struct LocalTaskStatusView: View {
        @ObservedObject
        private var viewStore: ViewStore<DebugDomain.State, DebugDomain.Action>

        init(store: DebugDomain.Store) {
            viewStore = ViewStore(store)
        }

        var body: some View {
            Section(header: Text("Local Task Status")) {
                VStack(alignment: .leading) {
                    Text("Fake task status for:")
                    HStack {
                        TextField("Test", text: viewStore.binding(
                            get: \.fakeTaskStatus,
                            send: DebugDomain.Action.setFaceErxTaskStatus
                        ))
                            .keyboardType(.numberPad)
                        Text("Seconds")
                            .foregroundColor(.gray)
                    }
                    .font(.system(.body, design: .monospaced))
                }
            }
        }
    }

    struct VirtualEGKLogin: View {
        private let store: DebugDomain.Store

        @ObservedObject
        private var viewStore: ViewStore<DebugDomain.State, DebugDomain.Action>

        init(store: DebugDomain.Store) {
            self.store = store
            viewStore = ViewStore(store)
        }

        @State var showScanVirtualEGK = false

        var body: some View {
            WithViewStore(store) { viewStore in
                Section(
                    header: Text("Virtual eGK Login"),
                    footer: Text("""
                    When enabled, the provided key and certificate is used instead of your NFC eGK.
                    Just go threw the regular 'Anmelden' screens. The entered CAN and PIN will be ignored.
                    """)
                ) {
                    Toggle("Use Virtual eGK instead of NFC",
                           isOn: viewStore.binding(
                               get: \.useVirtualLogin,
                               send: DebugDomain.Action.toggleVirtualLogin
                           )
                           .animation())
                                               .accessibilityIdentifier("debug_enable_virtual_egk")

                    if viewStore.useVirtualLogin {
                        NavigationLink(
                            destination: DebugEGKScannerView(
                                show: $showScanVirtualEGK,
                                prkCHAUTbase64: viewStore.binding(
                                    get: \.virtualLoginPrivateKey,
                                    send: DebugDomain.Action.virtualPrkCHAutReceived
                                ),
                                cCHAUTbase64: viewStore.binding(
                                    get: \.virtualLoginCertKey,
                                    send: DebugDomain.Action.virtualCCHAutReceived
                                )
                            ),
                            isActive: $showScanVirtualEGK
                        ) {
                            HStack {
                                Text("Scan virtual eGK")
                                Image(systemName: SFSymbolName.qrCode)
                            }
                        }

                        VStack {
                            TextEditor(text: viewStore.binding(
                                get: \.virtualLoginPrivateKey,
                                send: DebugDomain.Action.virtualPrkCHAutReceived
                            ))
                                .accessibility(identifier: "debug_prk_ch_aut")
                                .frame(minHeight: 100, maxHeight: 100)
                                .foregroundColor(Colors.systemLabel)
                                .border(Colors.separator)
                                .keyboardType(.default)
                                .disableAutocorrection(true)

                            FootnoteView(text: "Private Key as BASE64 (PrK_CH_AUT)", a11y: "dummy_a11y_i")
                        }

                        VStack {
                            TextEditor(text: viewStore.binding(
                                get: \.virtualLoginCertKey,
                                send: DebugDomain.Action.virtualCCHAutReceived
                            ))
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
        let store: DebugDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                Section(header: Text("Active Profile")) {
                    if let profile = viewStore.profile {
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
                            viewStore.send(.setProfileInsuranceTypeToPKV)
                        }
//                        .disabled(profile.insuranceType != .gKV)
                        .foregroundColor(profile.insuranceType == .gKV ? Color.orange : Color.gray)
                        .accessibilityIdentifier("debug_btn_mark_profile_as_pkv")

                        FootnoteView(
                            text: "Profiles that have been logged in may be marked as pKV profiles. Marked profiles may not be converted back.",
                            // swiftlint:disable:previous line_length
                            a11y: ""
                        )
                    } else {
                        Text("Loading current Profile...")
                    }
                }

                Section(header: Text("Login With Token")) {
                    Group {
                        TextEditor(text: viewStore.binding(
                            get: \.accessCodeText,
                            send: DebugDomain.Action.accessCodeTextReceived
                        ))
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
                        if viewStore.isAuthenticated ?? false {
                            Text("YES").bold().foregroundColor(.green)
                            Spacer()
                            Button("Logout") {
                                viewStore.send(.logoutButtonTapped)
                            }
                            .foregroundColor(.red)
                        } else {
                            Text("NO").bold().foregroundColor(.red)
                            Spacer()
                            Button("Login") {
                                withAnimation {
                                    UIApplication.shared.dismissKeyboard()
                                    viewStore.send(.loginWithToken)
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
                    Text(viewStore.token?.accessToken ?? "*** No valid token available ***")
                        .contextMenu(ContextMenu {
                            Button("Copy") {
                                UIPasteboard.general.string = viewStore.token?.accessToken
                            }
                        })
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: 100)
                        .foregroundColor(Colors.systemGray)
                        .background(Color(.systemGray5))
                        .accessibilityIdentifier("debug_txt_access_token_read")
                    if let date = viewStore.token?.expires {
                        let expires = dateFormatter.string(from: date)
                        FootnoteView(
                            text: "Access-token is valid until \(expires). Token can be copied with long touch.",
                            a11y: "dummy_a11y_i"
                        )
                    } else {
                        FootnoteView(text: "No valid access-token available", a11y: "dummy_a11y_i")
                    }
                    Button("Invalidate current access-token (which enforces using SSO-Token)") {
                        viewStore.send(.invalidateAccessToken)
                    }
                    Button("Delete SSO-Token and invalidate current access-token") {
                        viewStore.send(.deleteSSOToken)
                    }
                }
            }
        }
    }

    private struct LogSection: View {
        let store: DebugDomain.Store

        var body: some View {
            Section(header: Text("Logging")) {
                WithViewStore(store) { _ in
                    NavigationLink("Logs", destination: DebugLogsView(
                        store: store.scope(
                            state: \.logState,
                            action: DebugDomain.Action.logAction
                        )
                    ))
                }
            }
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
                Text(text)
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
        let store: DebugDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                Section(header: Text("Environment")) {
                    Picker("Environment",
                           selection: viewStore.binding(get: {
                                                            $0.selectedEnvironment?.name ?? "no selection"
                                                        },
                                                        send: { value in
                                                            DebugDomain.Action.setServerEnvironment(value)
                                                        })) {
                        ForEach(viewStore.availableEnvironments, id: \.id) { serverEnvironment in
                            Text(serverEnvironment.configuration.name).tag(serverEnvironment.name)
                        }
                    }

                    if let environment = viewStore.selectedEnvironment?.configuration {
                        HStack {
                            Text("Current")
                            Spacer()
                            Text(environment.name)
                        }
                        DebugView.TechDetail("IDP", value: environment.idp.absoluteString)
                        DebugView.TechDetail("FD", value: environment.erp.absoluteString)
                        DebugView.TechDetail("APO VZD", value: environment.apoVzd.absoluteString)
                    }

                    Button("Reset") {
                        viewStore.send(DebugDomain.Action.setServerEnvironment(nil))
                    }
                }
            }
        }
    }

    private struct FeatureFlagsSection: View {
        var body: some View {
            Section(header: Text("Feature Flags")) {
                NavigationLink(destination: FeatureFlags()) {
                    Text("Feature Flags")
                }
            }
        }

        private struct FeatureFlags: View {
            @AppStorage("enable_avs_login") var enableAvsLogin = false
            @AppStorage("show_debug_pharmacies") var showDebugPharmacies = false
            @AppStorage("enable_prescription_sharing") var isPrescriptionSharingEnabled = false

            var body: some View {
                List {
                    Toggle("Rezepte Teilen", isOn: $isPrescriptionSharingEnabled)

                    Toggle("Zuweisen ohne TI", isOn: $enableAvsLogin)

                    VStack(alignment: .leading) {
                        Toggle("Show Debug Pharmacies", isOn: $showDebugPharmacies)
                            .foregroundColor(enableAvsLogin ? Color(.label) : Color(.secondaryLabel))
                        Text("Zeigt die unter 'Debug Pharmacies' hinterlegten Apotheken in der Apothekensuche an")
                            .font(.footnote)
                            .foregroundColor(enableAvsLogin ? Color(.secondaryLabel) : Color(.tertiaryLabel))
                    }

                    NavigationLink(destination: AVSDebugView()) {
                        Text("Debug Pharmacies")
                    }.disabled(!enableAvsLogin)
                }
                .onChange(of: self.enableAvsLogin) { newValue in
                    showDebugPharmacies = newValue
                }
            }
        }
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DebugView(store: DebugDomain.Dummies.store)
        }
        .previewDevice("iPhone SE (2nd generation)")
    }
}

#endif
