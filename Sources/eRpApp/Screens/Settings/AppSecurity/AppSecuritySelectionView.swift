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

import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

struct AppSecuritySelectionView: View {
    let store: AppSecurityDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, AppSecurityDomain.Action>

    init(store: AppSecurityDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let destinationTag: AppSecurityDomain.Destinations.State.Tag?

        init(state: AppSecurityDomain.State) {
            destinationTag = state.destination?.tag
        }
    }

    var body: some View {
        VStack {
            SingleElementSectionContainer(
                header: { HeaderView(store: store) },
                content: {
                    SecuritySectionView(store: store)
                }
            )

            Spacer()

            NavigationLinkStore(
                store.scope(state: \.$destination, action: AppSecurityDomain.Action.destination),
                state: /AppSecurityDomain.Destinations.State.appPassword,
                action: AppSecurityDomain.Destinations.Action.appPassword,
                onTap: { viewStore.send(.setNavigation(tag: .appPassword)) },
                destination: CreatePasswordView.init(store:),
                label: {}
            )
            .hidden()
            .accessibility(hidden: true)

        }.onAppear {
            viewStore.send(.loadSecurityOption)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.stgBtnDeviceSecurity)
        .background(Color(.secondarySystemBackground))
    }

    private struct HeaderView: View {
        let store: AppSecurityDomain.Store
        @ObservedObject var viewStore: ViewStore<ViewState, AppSecurityDomain.Action>

        init(store: AppSecurityDomain.Store) {
            self.store = store
            viewStore = ViewStore(store, observe: ViewState.init)
        }

        struct ViewState: Equatable {
            let errorToDisplay: AppSecurityManagerError?

            init(state: AppSecurityDomain.State) {
                errorToDisplay = state.errorToDisplay
            }
        }

        var body: some View {
            if let error = viewStore.errorToDisplay {
                WarningView(text: error.errorDescription ?? "")
                    .accessibility(identifier: "stg_hnt_biometrics_warning")
            }
        }

        private struct WarningView: View {
            var text: String

            var body: some View {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: SFSymbolName.exclamationMark)
                        .foregroundColor(Colors.red900)
                        .font(.title3)
                        .padding(8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(text)
                            .font(Font.subheadline)
                            .foregroundColor(Colors.red900)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(8)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 12).fill(Colors.red100))
                .border(Colors.red300, width: 0.5, cornerRadius: 12)
            }
        }
    }
}

struct SecuritySectionView: View {
    let store: AppSecurityDomain.Store
    @ObservedObject var viewStore: ViewStore<ViewState, AppSecurityDomain.Action>

    init(store: AppSecurityDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let availableSecurityOptions: [AppSecurityOption]
        let selectedSecurityOption: AppSecurityOption?
        var isBiometricSelected = false
        var isPasswordSelected = false

        init(state: AppSecurityDomain.State) {
            availableSecurityOptions = state.availableSecurityOptions
            selectedSecurityOption = state.selectedSecurityOption
            isBiometricSelected = state.isBiometricSelected
            isPasswordSelected = state.isPasswordSelected
        }
    }

    var body: some View {
        ForEach(viewStore.state.availableSecurityOptions) { option in
            switch option {
            case let .biometry(biometryType):
                switch biometryType {
                case .faceID:
                    Toggle(isOn: viewStore.binding(get: \.isBiometricSelected,
                                                   send: .toggleBiometricSelected(.faceID))) {
                        Text(L10n.stgTxtSecurityOptionFaceidTitle)
                            .accessibility(identifier: A18n.settings.security.stgTxtSecurityFaceid)
                    }.toggleStyle(.switch)
                        .padding([.leading, .trailing, .top])
                case .touchID:
                    Toggle(isOn: viewStore.binding(get: \.isBiometricSelected,
                                                   send: .toggleBiometricSelected(.faceID))) {
                        Text(L10n.stgTxtSecurityOptionTouchidTitle)
                            .accessibility(identifier: A18n.settings.security.stgTxtSecurityTouchid)
                    }.toggleStyle(.switch)
                        .padding([.leading, .trailing, .top])
                }
            case .password:
                GreyDivider(topPadding: 0).ignoresSafeArea()

                Toggle(isOn: viewStore.binding(get: \.isPasswordSelected,
                                               send: .togglePasswordSelected)) {
                    Text(L10n.stgTxtSecurityOptionPasswordTitle)
                        .accessibility(identifier: A18n.settings.security.stgTxtSecurityPassword)
                }
                .padding([.leading, .trailing, .bottom])
                .toggleStyle(.switch)
                .modifier(SectionContainerCellModifier())
            case .unsecured,
                 .biometryAndPassword:
                EmptyView()
            }
        }
    }
}

struct AppSecuritySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppSecuritySelectionView(store: AppSecurityDomain.Dummies.store)
        }
    }
}
