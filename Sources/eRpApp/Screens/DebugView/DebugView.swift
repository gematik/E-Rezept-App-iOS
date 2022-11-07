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
                TutorialSection(store: store)
                LoginSection(store: store)
                CardWallSection(store: store)
            }
            .listStyle(GroupedListStyle())
            .respectKeyboardInsets()
            .background(Colors.backgroundSecondary)
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
    // MARK: - screen related view

    private struct ResetButton: View {
        let text: String
        let action: () -> Void

        var body: some View {
            Button(text, action: action)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
        }
    }

    private struct TutorialSection: View {
        let store: DebugDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                Section(header: Text("Tutorial/Onboarding")) {
                    VStack {
                        Toggle("Hide Onboarding", isOn: viewStore.binding(
                            get: \.hideOnboarding,
                            send: DebugDomain.Action.hideOnboardingToggleTapped
                        ))
                        FootnoteView(text: "Intro is only displayed once. Needs App restart.", a11y: "dummy_a11y_l")
                    }
                    DebugView.ResetButton(text: "Reset hint events") {
                        viewStore.send(.resetHintEvents)
                    }
                    Toggle("Tracking OptOut",
                           isOn: viewStore.binding(
                               get: { state in state.trackingOptIn },
                               send: DebugDomain.Action.toggleTrackingTapped
                           ))
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
                    DebugView.ResetButton(text: "Reset CAN") {
                        viewStore.send(.resetCanButtonTapped)
                    }
                    DebugView.ResetButton(text: "Reset Biometrie (Key and Cert)") {
                        viewStore.send(.deleteKeyAndEGKAuthCertForBiometric)
                    }
                    DebugView.ResetButton(text: "Reset CERT- and OCSP-Lists") {
                        viewStore.send(.resetOcspAndCertListButtonTapped)
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
                }
            }
        }
    }

    private struct LoginSection: View {
        @Injected(\.fhirDateFormatter) var dateFormatter: FHIRDateFormatter
        let store: DebugDomain.Store

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
                    SectionHeaderView(text: "Virtual eGK Login", a11y: "dummy_a11y_i")
                    Toggle("Use Virtual eGK instead of NFC",
                           isOn: viewStore.binding(
                               get: \.useVirtualLogin,
                               send: DebugDomain.Action.toggleVirtualLogin
                           )
                           .animation())
                                               .accessibilityIdentifier("debug_enable_virtual_egk")
                    if viewStore.useVirtualLogin {
                        FootnoteView(
                            // swiftlint:disable:next line_length
                            text: "The following key + certificate pair is used instead of your NFC eGK within the Cardwall.",
                            a11y: "dummy_a11y_i"
                        )

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
                                .border(Color.black)
                                .keyboardType(.default)
                                .disableAutocorrection(true)

                            FootnoteView(text: "PrK_CH_AUT (BASE64)", a11y: "dummy_a11y_i")
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
                                .border(Color.black)
                                .disableAutocorrection(true)

                            FootnoteView(text: "C.CH.AUT (BASE64)", a11y: "dummy_a11y_i")
                        }
                    }
                }
            }
        }

        var body: some View {
            WithViewStore(store) { viewStore in
                Section(header: Text("Login State")) {
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

                    VirtualEGKLogin(store: store)

                    SectionHeaderView(text: "Manual Login with Token:", a11y: "dummy_a11y_i")
                    Group {
                        TextEditor(text: viewStore.binding(
                            get: \.accessCodeText,
                            send: DebugDomain.Action.accessCodeTextReceived
                        ))
                            .accessibilityIdentifier("debug_txt_access_token_write")
                            .frame(minHeight: 100, maxHeight: 100)
                            .background(Color(.systemGray5))
                            .foregroundColor(Colors.systemLabel)
                            .keyboardType(.default)
                            .disableAutocorrection(true)
                        FootnoteView(
                            text: "Initial access token can only be used for gematik IDP. Token will be updated to the latest used token after using logout here",
                            // swiftlint:disable:previous line_length
                            a11y: ""
                        )
                    }

                    SectionHeaderView(text: "Current access token", a11y: "dummy_a11y_i")
                    Text(viewStore.token?.accessToken ?? "*** No valid token available ***")
                        .contextMenu(ContextMenu {
                            Button("Copy") {
                                UIPasteboard.general.string = viewStore.token?.accessToken
                            }
                        })
                        .animation(.easeInOut)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: 100)
                        .foregroundColor(Colors.systemGray)
                        .background(Color(.systemGray5))
                        .accessibilityIdentifier("debug_txt_access_token_read")
                    if let date = viewStore.token?.expires,
                       let expires = dateFormatter.string(from: date) {
                        FootnoteView(
                            text: "Access token is valid until \(expires). Token can be copied with long touch.",
                            a11y: "dummy_a11y_i"
                        )
                    } else {
                        FootnoteView(text: "No valid access token available", a11y: "dummy_a11y_i")
                    }
                    DebugView.ResetButton(text: "Delete SSOToken and expire current access token") {
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
