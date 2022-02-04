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
import SwiftUI
import UIKit

struct CardWallPINView<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let store: CardWallPINDomain.Store
    let nextView: (String) -> Content

    init(store: CardWallPINDomain.Store, @ViewBuilder nextView: @escaping (String) -> Content) {
        self.store = store
        self.nextView = nextView
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                PINView(store: store).padding()

                NavigationLink(
                    destination: nextView(viewStore.pin),
                    isActive: viewStore.binding(
                        get: \.showNextScreen,
                        send: CardWallPINDomain.Action.reset
                    )
                ) {
                    EmptyView()
                }.accessibility(hidden: true)

                Spacer()

                GreyDivider()

                PrimaryTextButton(text: L10n.cdwBtnPinDone,
                                  a11y: A11y.cardWall.pinInput.cdwBtnPinDone,
                                  isEnabled: viewStore.state.enteredPINValid) {
                    viewStore.send(.advance)
                }
                .accessibility(label: Text(L10n.cdwBtnPinDoneLabel))
                .padding(.horizontal)
                .padding(.bottom)
            }
            .demoBanner(isPresented: viewStore.isDemoModus) {
                Text(L10n.cdwTxtPinDemoModeInfo)
            }
            .navigationBarTitle(L10n.cdwTxtPinTitle, displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: CustomNavigationBackButton(presentationMode: presentationMode),
                trailing: NavigationBarCloseItem {
                    viewStore.send(.close)
                }
                .accessibility(identifier: A11y.cardWall.pinInput.cdwBtnPinCancel)
                .accessibility(label: Text(L10n.cdwBtnPinCancelLabel))
            )
        }
    }
}

extension CardWallPINView {
    // MARK: - screen related views

    private struct PINView: View {
        let store: CardWallPINDomain.Store

        var body: some View {
            WithViewStore(store) { viewStore in
                ScrollView(.vertical, showsIndicators: true) {
                    if viewStore.state.wrongPinEntered {
                        WorngPINEnteredWarningView().padding()
                    }

                    VStack(alignment: .leading) {
                        Text(L10n.cdwTxtPinSubtitle)
                            .foregroundColor(Colors.systemLabel)
                            .font(.title3)
                            .bold()
                            .accessibility(identifier: A11y.cardWall.pinInput.cdwTxtPinSubtitle)
                            .padding(.bottom, 16)

                        PINFieldView(store: store) {
                            withAnimation {
                                viewStore.send(.advance)
                            }
                        }.padding(.bottom, 32)

                        HintView<CardWallCANDomain.Action>(
                            hint: Hint(id: A11y.cardWall.pinInput.cdwHintGetPin,
                                       title: L10n.cdwHintPinTitle.text,
                                       message: L10n.cdwHintPinMsg.text,
                                       actionText: nil, // L10n.cdwHintPinBtn
                                       action: nil,
                                       imageName: Asset.CardWall.arzt1.name,
                                       closeAction: nil,
                                       style: .neutral,
                                       buttonStyle: .tertiary,
                                       imageStyle: .topAligned),
                            textAction: {},
                            closeAction: nil
                        )
                    }
                }
                .respectKeyboardInsets()
            }
        }
    }

    private struct PINFieldView: View {
        let store: CardWallPINDomain.Store

        let completion: () -> Void

        var body: some View {
            VStack(alignment: .leading) {
                WithViewStore(store) { viewStore in
                    SecureField(
                        L10n.cdwEdtPinInput,
                        text: viewStore.binding(get: \.pin, send: CardWallPINDomain.Action.update(pin:)).animation()
                    )
                    .textContentType(.oneTimeCode)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .padding()
                    .font(Font.title3.bold())
                    .background(Colors.systemGray5)
                    .cornerRadius(8)
                    .textFieldKeepFirstResponder()
                    .accessibility(identifier: A11y.cardWall.pinInput.cdwEdtPinInput)
                    .accessibility(label: Text(L10n.cdwTxtPinInputLabel))

                    if !viewStore.showWarning {
                        Text(L10n.cdwTxtPinHint)
                            .font(.footnote)
                            .foregroundColor(Colors.systemLabelSecondary)
                            .accessibility(identifier: A11y.cardWall.pinInput.cdwTxtPinHint)
                    } else {
                        // PIN count out-of-bounds warn message // todo styling
                        HStack(spacing: 4) {
                            Image(systemName: SFSymbolName.exclamationMark)
                                .foregroundColor(Colors.alertNegativ)
                                .font(.footnote)

                            Text(viewStore.warningMessage)
                                .font(.footnote)
                                .foregroundColor(Colors.alertNegativ)
                                .accessibility(identifier: A11y.cardWall.pinInput.cdwTxtPinWarning)

                            Spacer()
                        }
                    }
                }
            }
        }
    }

    private struct WorngPINEnteredWarningView: View {
        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: SFSymbolName.exclamationMark)
                    .foregroundColor(Colors.red900)
                    .font(.title3)
                    .padding(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.cdwTxtPinWarnWrongTitle)
                        .font(Font.subheadline.weight(.semibold))
                        .foregroundColor(Colors.red900)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(L10n.cdwTxtPinWarnWrongDescription)
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
}

struct MyPINView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(["iPhone SE (1st generation)", "iPhone 11"], id: \.self) { deviceName in
                NavigationView {
                    CardWallPINView(
                        store: CardWallPINDomain.Dummies.store
                    ) { _ in
                        EmptyView()
                    }
                }
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
            }
        }
    }
}
