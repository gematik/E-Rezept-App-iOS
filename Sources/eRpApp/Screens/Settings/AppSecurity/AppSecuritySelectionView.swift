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
import SwiftUI

struct AppSecuritySelectionView: View {
    typealias AppSecurityOption = AppSecurityDomain.AppSecurityOption

    let store: AppSecurityDomain.Store
    @ObservedObject
    var viewStore: ViewStore<AppSecurityDomain.State, AppSecurityDomain.Action>

    init(store: AppSecurityDomain.Store) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                if viewStore.state.selectedSecurityOption == nil {
                    WarningView(text: NSLocalizedString("stg_txt_security_warning",
                                                        comment: "stg_hnt_security_warning"))
                        .accessibility(identifier: "")
                } else if case .unsecured = viewStore.state.selectedSecurityOption {
                    WarningView(text: NSLocalizedString("stg_txt_security_warning",
                                                        comment: "stg_hnt_security_warning"))
                        .accessibility(identifier: "")
                }

                if let error = viewStore.state.errorToDisplay {
                    WarningView(text: error.errorDescription ?? "")
                        .accessibility(identifier: "stg_hnt_biometrics_warning")
                }

                VStack {
                    ForEach(viewStore.state.availableSecurityOptions.indices, id: \.self) { index in
                        if index != 0 {
                            Divider()
                        }

                        let option = viewStore.state.availableSecurityOptions[index]
                        selectionCellForSecurityOption(option,
                                                       binding: viewStore.binding(
                                                           get: { $0.selectedSecurityOption == option },
                                                           send: .select(option)
                                                       )
                                                       .animation())
                    }
                }
                .background(Colors.systemBackgroundTertiary)
                .border(Colors.systemColorClear, cornerRadius: 16)

                NavigationLink(
                    destination: IfLetStore(
                        store.scope(
                            state: { $0.createPasswordState },
                            action: { AppSecurityDomain.Action.createPassword(action: $0) }
                        )
                    ) { store in
                        CreatePasswordView(store: store)
                    },
                    isActive: viewStore.binding(
                        get: \.showCreatePasswordScreen,
                        send: AppSecurityDomain.Action.hideCreatePasswordScreen
                    )
                ) {
                    EmptyView()
                }.accessibility(hidden: true)
            }
            .onAppear {
                viewStore.send(.loadSecurityOption)
            }
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
            .background(RoundedRectangle(cornerRadius: 16).fill(Colors.red100))
            .border(Colors.red300, width: 0.5, cornerRadius: 16)
        }
    }

    private func selectionCellForSecurityOption(_ option: AppSecurityOption,
                                                binding: Binding<Bool>) -> SelectionCell? {
        switch option {
        case let .biometry(biometryType):
            switch biometryType {
            case .faceID:
                return SelectionCell(
                    text: L10n.stgTxtSecurityOptionFaceidTitle,
                    description: nil,
                    a11y: A18n.settings.security.stgTxtSecurityFaceid,
                    systemImage: SFSymbolName.faceId,
                    isOn: binding
                )
            case .touchID:
                return SelectionCell(
                    text: L10n.stgTxtSecurityOptionTouchidTitle,
                    description: nil,
                    a11y: A18n.settings.security.stgTxtSecurityTouchid,
                    systemImage: SFSymbolName.touchId,
                    isOn: binding
                )
            }
        case .password:
            return SelectionCell(
                text: L10n.stgTxtSecurityOptionPasswordTitle,
                description: nil,
                a11y: A18n.settings.security.stgTxtSecurityPassword,
                systemImage: SFSymbolName.rectangleAndPencilAndEllipsis,
                isOn: binding
            )
        case .unsecured:
            return SelectionCell(
                text: L10n.stgTxtSecurityOptionUnsecuredTitle,
                description: L10n.stgTxtSecurityOptionNoneDescription,
                a11y: A18n.settings.security.stgTxtSecurityUnsecured,
                systemImage: SFSymbolName.lockOpen,
                isOn: binding
            )
        }
    }
}

struct AppSecuritySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppSecuritySelectionView(store: AppSecurityDomain.Dummies.store).generateVariations()
        }
    }
}
