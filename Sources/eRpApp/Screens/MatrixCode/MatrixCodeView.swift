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
        erxChargeItem?.medication?.displayName ?? "-"
    }

    var disableShareButton: Bool {
        type != .erxTask
    }
}

// [REQ:gemSpec_eRp_FdV:A_20181-01#2] Screen that presents the DataMatrix code for redeeming a prescription only
// contains some static texts and the image of the code.
struct MatrixCodeView: View {
    @Perception.Bindable var store: StoreOf<MatrixCodeDomain>
    @State var originalBrightness: CGFloat?

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

                TabBarView(store: store)

                if store.state.type == .erxChargeItem {
                    Text(title)
                        .foregroundColor(Colors.systemLabel)
                        .font(Font.subheadline.bold())
                        .padding(.bottom)
                        .accessibility(identifier: A18n.matrixCode.dmcTxtTitle)
                    Text(store.state.medicationName)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Colors.systemLabelSecondary)
                        .font(Font.subheadline)
                        .accessibility(identifier: A18n.matrixCode.dmcTxtTitle)
                }

                Spacer()
            }
            .navigationBarItems(
                trailing: Button(
                    action: {
                        store.send(.shareButtonTapped)
                    }, label: {
                        Label(L10n.prscDtlBtnShare, systemImage: SFSymbolName.share)
                    }
                )
                .disabled(store.disableShareButton)
                .accessibility(identifier: A18n.matrixCode.dmcBtnShare)
            )
            .sheet(item: $store.scope(
                state: \.destination?.sharePrescription,
                action: \.destination.sharePrescription
            )) { scopedStore in
                ShareViewController(
                    store: scopedStore
                )
            }
            .onAppear {
                store.send(.loadMatrixCodeImage(screenSize: UIScreen.main.bounds.size))
                originalBrightness = UIScreen.main.brightness
            }
            .onDisappear {
                if let originalBrightness = originalBrightness {
                    UIScreen.main.brightness = originalBrightness
                }
            }
        }
    }

    struct TabBarView: View {
        @Perception.Bindable var store: StoreOf<MatrixCodeDomain>

        // TabView used for creating the paging effect is very greedy with space. We calculate the size beforehand to
        // accomodate that.
        static let deviceWidth: CGFloat = UIScreen.main.bounds.width
        static let pagedPartHeight: CGFloat = {
            deviceWidth + 33
        }()

        var body: some View {
            WithPerceptionTracking {
                VStack(spacing: 0) {
                    switch store.loadingState {
                    case .loading:
                        ProgressView()
                            .accessibility(identifier: A18n.matrixCode.dmcImgLoadingIndicator)
                    case let .value(images):
                        if let singleImage = images.first,
                           images.count == 1 {
                            if let chunk = singleImage.chunk {
                                SelfPayerWarningView(erxTasks: chunk)
                                    .padding(.horizontal)
                            }
                            SingleMatrixCode(image: singleImage.image, isZoomed: store.isMatrixCodeZoomed) {
                                store.send(.zoomButtonTapped, animation: .default)
                            }

                            if let chunk = singleImage.chunk {
                                Text(chunk.count > 1 ? L10n.dmcTxtCodeMultiple : L10n.dmcTxtCodeSingle)
                                    .font(.headline)
                                    .padding(.bottom, 8)

                                HStack {
                                    Text(
                                        "\(chunk.compactMap { $0.medication?.displayName }.joined(separator: " & "))"
                                    )
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity)
                                }
                                .multilineTextAlignment(.center)
                                .animation(.easeInOut.delay(0.2), value: store.page)
                            }

                            Spacer()
                        } else {
                            if let chunk = images[store.page].chunk {
                                SelfPayerWarningView(erxTasks: chunk)
                                    .padding(.horizontal)
                            }

                            TabView(selection: $store.page.sending(\.pageChanged)) {
                                ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                                    WithPerceptionTracking {
                                        SingleMatrixCode(image: image.image, isZoomed: store.isMatrixCodeZoomed) {
                                            store.send(.zoomButtonTapped, animation: .default)
                                        }
                                        .tag(index)
                                    }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .frame(width: Self.deviceWidth, height: Self.pagedPartHeight)

                            HStack {
                                Spacer()
                                PageControl(
                                    numberOfPages: images.count,
                                    currentPage: $store.page.sending(\.pageChanged)
                                )
                                Spacer()
                            }
                            .padding(.bottom, 40)

                            if let chunk = images[store.page].chunk {
                                Text(chunk.count > 1 ? L10n.dmcTxtCodeMultiple : L10n.dmcTxtCodeSingle)
                                    .font(.headline)
                                    .padding(.bottom, 8)

                                HStack {
                                    Text(
                                        "\(chunk.compactMap { $0.medication?.displayName }.joined(separator: " & "))"
                                    )
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity)
                                }
                                .multilineTextAlignment(.center)
                                .animation(.easeInOut.delay(0.2), value: store.page)
                            }

                            Spacer()
                        }
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }
}

extension MatrixCodeView.TabBarView {
    struct SingleMatrixCode: View {
        let image: UIImage
        let isZoomed: Bool
        let action: () -> Void

        var body: some View {
            VStack(spacing: 0) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(isZoomed ? 16 : 64)
                    .accessibility(label: Text(L10n.rphTxtMatrixcodeHint))
                    .accessibility(identifier: A18n.matrixCode.dmcImgMatrixcode)

                HStack {
                    Spacer()

                    Button {
                        action()
                    } label: {
                        Image(systemName: isZoomed ? SFSymbolName.magnifyingGlasMinus : SFSymbolName.magnifyingGlasPlus)
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
