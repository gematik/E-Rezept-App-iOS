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
import SwiftUI

// [REQ:gemSpec_eRp_FdV:A_20181#1] Screen that presents the DataMatrix code for redeeming a prescription only contains
//   some static texts and the image of the code.
struct MatrixCodeView: View {
    let store: MatrixCodeDomain.Store
    @State var originalBrightness: CGFloat?
    @ObservedObject var viewStore: ViewStore<ViewState, MatrixCodeDomain.Action>

    init(store: MatrixCodeDomain.Store) {
        self.store = store
        viewStore = ViewStore(store, observe: ViewState.init)
    }

    struct ViewState: Equatable {
        let isShowAlert: Bool
        let isZoomedIn: Bool
        let loadingState: LoadingState<UIImage, MatrixCodeDomain.LoadingImageError>
        let matrixCodeType: MatrixCodeDomain.MatrixCodeType
        let medicationName: String

        init(state: MatrixCodeDomain.State) {
            isShowAlert = state.isShowAlert
            isZoomedIn = state.isZoomedIn
            loadingState = state.loadingState
            matrixCodeType = state.type
            medicationName = state.erxChargeItem?.medication?.name ?? "-"
        }
    }

    var title: StringAsset {
        switch viewStore.matrixCodeType {
        case .erxTask: return L10n.rphTxtTitle
        case .erxChargeItem: return L10n.stgTxtChargeItemAlterPharmacyTitle
        }
    }

    var subtitle: StringAsset {
        switch viewStore.matrixCodeType {
        case .erxTask: return L10n.rphTxtSubtitle
        case .erxChargeItem: return L10n.stgTxtChargeItemAlterPharmacySubtitle
        }
    }

    var body: some View {
        VStack {
            if viewStore.matrixCodeType == .erxTask {
                Text(title)
                    .foregroundColor(Colors.systemLabel)
                    .font(Font.title.bold())
                    .accessibility(identifier: A18n.matrixCode.dmcTxtTitle)
            }
            Text(subtitle)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .padding()
                .foregroundColor(Colors.systemLabelSecondary)
                .accessibility(identifier: A18n.matrixCode.dmcTxtSubtitle)
            VStack(alignment: .trailing) {
                switch viewStore.state.loadingState {
                case .loading:
                    ProgressView()
                        .accessibility(identifier: A18n.matrixCode.dmcImgLoadingIndicator)
                case let .value(value):
                    Image(uiImage: value)
                        .resizable()
                        .scaledToFit()
                        .padding(64)
                        .accessibility(label: Text(L10n.rphTxtMatrixcodeHint))
                        .accessibility(identifier: A18n.matrixCode.dmcImgMatrixcode)

                    Button {
                        viewStore.send(.zoomButtonTapped, animation: .default)
                    } label: {
                        Image(systemName: SFSymbolName.magnifyingGlasPlus)
                            .font(Font.body.bold())
                            .foregroundColor(Colors.primary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                    }
                    .background(Colors.backgroundSecondary)
                    .border(Colors.separator, cornerRadius: 8)
                    .frame(alignment: .bottomTrailing)
                    .padding(.horizontal)
                    .padding(.bottom)
                default:
                    EmptyView()
                }
            }
            .background(Colors.systemColorWhite) // No darkmode to get contrast
            .border(Colors.separator, cornerRadius: 16)
            .padding()

            if viewStore.matrixCodeType == .erxChargeItem {
                Text(title)
                    .foregroundColor(Colors.systemLabel)
                    .font(Font.subheadline.bold())
                    .padding(.bottom)
                    .accessibility(identifier: A18n.matrixCode.dmcTxtTitle)
                Text(viewStore.medicationName)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .font(Font.subheadline)
                    .accessibility(identifier: A18n.matrixCode.dmcTxtTitle)
            }

            Spacer()
        }
        .navigationBarItems(trailing: Button(
            action: {
                viewStore.send(.closeButtonTapped)
            }, label: {
                Text(L10n.dmcBtnClose)
            }
        )
        .accessibility(identifier: A18n.matrixCode.dmcBtnClose))
        .navigationBarBackButtonHidden(true)
        .alert(
            L10n.rphTxtCloseAlertTitle.key,
            isPresented: .constant(viewStore.isShowAlert),
            actions: {
                Button(L10n.rphBtnCloseAlertKeep.key, role: .cancel) {
                    viewStore.send(.closeButtonTapped)
                }
                Button(L10n.rphBtnCloseAlertMarkRedeemed.key, role: .destructive) {
                    viewStore.send(.closeButtonTapped)
                }
            }, message: {
                Text(L10n.rphTxtCloseAlertMessage)
            }
        )
        .onAppear {
            viewStore.send(.loadMatrixCodeImage(screenSize: UIScreen.main.bounds.size))
            originalBrightness = UIScreen.main.brightness
        }
        .overlay {
            if viewStore.isZoomedIn, let image = viewStore.loadingState.value {
                Button {
                    viewStore.send(.closeZoomTapped)
                } label: {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .accessibility(label: Text(L10n.rphTxtMatrixcodeHint))
                        .accessibility(identifier: A18n.matrixCode.dmcImgMatrixcode)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(Colors.systemColorWhite)
                .onAppear {
                    UIScreen.main.brightness = CGFloat(1.0)
                }
                .onDisappear {
                    if let originalBrightness = originalBrightness {
                        UIScreen.main.brightness = originalBrightness
                    }
                }
            }
        }
    }
}

struct ErxTaskMatrixCodeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MatrixCodeView(
                store: MatrixCodeDomain.Dummies.store
            )
            MatrixCodeView(
                store: MatrixCodeDomain.Dummies.store
            )
            .preferredColorScheme(.dark)
        }
    }
}

struct ErxChargeItemMatrixCodeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MatrixCodeView(
                store: MatrixCodeDomain.Dummies.storeFor(MatrixCodeDomain.Dummies.erxChargeItemState)
            )
            MatrixCodeView(
                store: MatrixCodeDomain.Dummies.storeFor(MatrixCodeDomain.Dummies.erxChargeItemState)
            )
            .preferredColorScheme(.dark)
        }
    }
}
