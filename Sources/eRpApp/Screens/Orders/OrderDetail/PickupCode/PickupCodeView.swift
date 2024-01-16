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

struct PickupCodeView: View {
    let store: PickupCodeDomain.Store
    @State var originalBrightness: CGFloat?
    @ObservedObject var viewStore: ViewStoreOf<PickupCodeDomain>

    init(store: PickupCodeDomain.Store) {
        self.store = store
        viewStore = ViewStore(store) { $0 }
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    if let dmcCode = viewStore.pickupCodeDMC {
                        DMCView(image: viewStore.dmcImage, dmcCode: dmcCode)
                            .padding(.horizontal, 8)
                            .padding(.vertical)
                    }

                    if let hrCode = viewStore.pickupCodeHR {
                        HRCodeView(code: hrCode)
                            .padding(.vertical, 8)
                    }

                    TitleView(store: store)
                }
            }
            .navigationBarItems(trailing: CloseButton { viewStore.send(.delegate(.close)) })
            .navigationBarTitleDisplayMode(.inline)
            .introspectNavigationController { navigationController in
                let navigationBar = navigationController.navigationBar
                navigationBar.barTintColor = UIColor(Colors.systemBackground)
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)
                navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
                navigationBar.standardAppearance = navigationBarAppearance
            }
            .task {
                await viewStore.send(.loadMatrixCodeImage(screenSize: UIScreen.main.bounds.size)).finish()
            }
            .onAppear {
                originalBrightness = UIScreen.main.brightness
            }
            .onDisappear {
                if let originalBrightness = originalBrightness {
                    UIScreen.main.brightness = originalBrightness
                }
            }
        }
        .accentColor(Colors.primary600)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    struct TitleView: View {
        let store: PickupCodeDomain.Store
        @ObservedObject var viewStore: ViewStoreOf<PickupCodeDomain>

        init(store: PickupCodeDomain.Store) {
            self.store = store
            viewStore = ViewStore(store) { $0 }
        }

        var body: some View {
            VStack(spacing: 8) {
                Text(L10n.pucTxtTitle)
                    .foregroundColor(Colors.systemLabel)
                    .font(Font.subheadline.weight(.semibold))
                    .accessibility(identifier: A11y.orderDetail.pickupCode.pucTxtTitle)

                let name = viewStore.pharmacyName ?? L10n.ordTxtNoPharmacyName.text
                Text(L10n.pucTxtSubtitle(name))
                    .foregroundColor(Colors.systemLabelSecondary)
                    .font(Font.subheadline)
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: A11y.orderDetail.pickupCode.pucTxtSubtitle)
            }
        }
    }

    struct HRCodeView: View {
        let code: String
        var body: some View {
            Text(code)
                .foregroundColor(Colors.systemLabelSecondary)
                .font(Font.subheadline.weight(.semibold))
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Colors.systemBackgroundSecondary))
                .accessibility(identifier: A11y.orderDetail.pickupCode.pucTxtHrCode)
        }
    }

    struct DMCView: View {
        let image: UIImage?
        let dmcCode: String
        var body: some View {
            VStack {
                if let dmcImage = image {
                    Image(uiImage: dmcImage)
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .background(Colors.systemColorWhite)
                } else {
                    Text(dmcCode)
                        .font(.subheadline)
                        .foregroundColor(Colors.systemLabelSecondary)
                }
            }
        }
    }
}

struct PickupCodeView_Previews: PreviewProvider {
    static var previews: some View {
        PickupCodeView(store: PickupCodeDomain.Dummies.store)
    }
}
