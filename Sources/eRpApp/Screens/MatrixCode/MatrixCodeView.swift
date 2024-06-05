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
import eRpStyleKit
import SwiftUI

extension MatrixCodeDomain.State {
    var medicationName: String {
        erxChargeItem?.medication?.name ?? "-"
    }
}

// [REQ:gemSpec_eRp_FdV:A_20181-01#2] Screen that presents the DataMatrix code for redeeming a prescription only
// contains some static texts and the image of the code.
struct MatrixCodeView: View {
    @Perception.Bindable var store: StoreOf<MatrixCodeDomain>
    @State var originalBrightness: CGFloat?

    @State var page = 0

    init(store: StoreOf<MatrixCodeDomain>) {
        self.store = store
    }

    var title: StringAsset {
        switch store.type {
        case .erxTask: return L10n.rphTxtTitle
        case .erxChargeItem: return L10n.stgTxtChargeItemAlterPharmacyTitle
        }
    }

    var subtitle: StringAsset {
        switch store.type {
        case .erxTask: return L10n.rphTxtSubtitle
        case .erxChargeItem: return L10n.stgTxtChargeItemAlterPharmacySubtitle
        }
    }

    // TabView used for creating the paging effect is very greedy with space. We calculate the size beforehand to
    // accomodate that.
    static let deviceWidth: CGFloat = UIScreen.main.bounds.width
    static let pagedPartHeight: CGFloat = {
        deviceWidth + 33
    }()

    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                if store.type == .erxTask {
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

                switch store.state.loadingState {
                case .loading:
                    ProgressView()
                        .accessibility(identifier: A18n.matrixCode.dmcImgLoadingIndicator)
                case let .value(images):
                    if let singleImage = images.first,
                       images.count == 1 {
                        VStack(spacing: 0) {
                            SingleMatrixCode(image: singleImage.image) {
                                store.send(.zoomButtonTapped(singleImage.id), animation: .default)
                            }

                            if let chunk = singleImage.chunk {
                                Text(chunk.count > 1 ? L10n.dmcTxtCodeMultiple : L10n.dmcTxtCodeSingle)
                                    .font(.headline)
                                    .padding(.bottom, 8)

                                HStack {
                                    Text("\(chunk.compactMap { $0.medication?.displayName }.joined(separator: ", "))")
                                        .padding(.horizontal)
                                        .frame(maxWidth: .infinity)
                                }
                                .multilineTextAlignment(.center)
                                .animation(.easeInOut.delay(0.2), value: page)
                            }

                            Spacer()
                        }
                    } else {
                        VStack(spacing: 0) {
                            TabView(selection: $page) {
                                ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                                    SingleMatrixCode(image: image.image) {
                                        store.send(.zoomButtonTapped(image.id), animation: .default)
                                    }
                                    .tag(index)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .frame(width: Self.deviceWidth, height: Self.pagedPartHeight)

                            HStack {
                                Spacer()
                                PageControl(numberOfPages: images.count, currentPage: $page)
                                Spacer()
                            }
                            .padding(.bottom, 40)

                            if let chunk = images[page].chunk {
                                Text(chunk.count > 1 ? L10n.dmcTxtCodeMultiple : L10n.dmcTxtCodeSingle)
                                    .font(.headline)
                                    .padding(.bottom, 8)

                                HStack {
                                    Text("\(chunk.compactMap { $0.medication?.displayName }.joined(separator: ", "))")
                                        .padding(.horizontal)
                                        .frame(maxWidth: .infinity)
                                }
                                .multilineTextAlignment(.center)
                                .animation(.easeInOut.delay(0.2), value: page)
                            }

                            Spacer()
                        }
                    }
                default:
                    EmptyView()
                }

                if store.type == .erxChargeItem {
                    Text(title)
                        .foregroundColor(Colors.systemLabel)
                        .font(Font.subheadline.bold())
                        .padding(.bottom)
                        .accessibility(identifier: A18n.matrixCode.dmcTxtTitle)
                    Text(store.medicationName)
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
                    store.send(.closeButtonTapped)
                }, label: {
                    Text(L10n.dmcBtnClose)
                }
            )
            .accessibility(identifier: A18n.matrixCode.dmcBtnClose))
            .navigationBarBackButtonHidden(true)
            .alert(
                L10n.rphTxtCloseAlertTitle.key,
                isPresented: .constant(store.isShowAlert),
                actions: {
                    Button(L10n.rphBtnCloseAlertKeep.key, role: .cancel) {
                        store.send(.closeButtonTapped)
                    }
                    Button(L10n.rphBtnCloseAlertMarkRedeemed.key, role: .destructive) {
                        store.send(.closeButtonTapped)
                    }
                }, message: {
                    Text(L10n.rphTxtCloseAlertMessage)
                }
            )
            .onAppear {
                store.send(.loadMatrixCodeImage(screenSize: UIScreen.main.bounds.size))
                originalBrightness = UIScreen.main.brightness
            }
            .overlay {
                if let imageId = store.zoomedInto,
                   let images = store.loadingState.value,
                   let image = images[id: imageId]?.image {
                    Button {
                        store.send(.closeZoomTapped)
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
}

struct SingleMatrixCode: View {
    let image: UIImage
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding(16)
                .accessibility(label: Text(L10n.rphTxtMatrixcodeHint))
                .accessibility(identifier: A18n.matrixCode.dmcImgMatrixcode)

            HStack {
                Spacer()

                Button {
                    action()
                } label: {
                    Image(systemName: SFSymbolName.magnifyingGlasPlus)
                        .font(Font.body.bold())
                        .foregroundColor(Colors.primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                }
                .background(Colors.backgroundSecondary)
                .border(Colors.separator, cornerRadius: 8)
                .frame(width: 55, height: 33)
                .padding(.horizontal, 16)
                .padding(.bottom)
            }
        }
        .background(Colors.backgroundNeutral)
        .border(Colors.separator, cornerRadius: 16)
        .environment(\.colorScheme, .light)
        .padding()
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
