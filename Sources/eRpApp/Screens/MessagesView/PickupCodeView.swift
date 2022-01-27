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

struct PickupCodeView: View {
    let store: PickupCodeDomain.Store
    @State var originalBrightness: CGFloat?

    init(store: PickupCodeDomain.Store) {
        self.store = store
    }

    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                VStack(spacing: 0) {
                    ScrollView(.vertical) {
                        TitleView()
                            .padding(.bottom, 32)

                        if let hrCode = viewStore.pickupCodeHR {
                            HRCodeView(code: hrCode)
                        }

                        if let dmcCode = viewStore.pickupCodeDMC,
                           let dmcImage = viewStore.dmcImage {
                            DMCView(image: dmcImage, dmcCode: dmcCode)
                                .padding(.horizontal, 8)
                                .padding(.bottom)
                        }
                    }
                }
                .navigationBarItems(trailing: CloseButton { viewStore.send(.close) })
                .navigationBarTitleDisplayMode(.inline)
                .introspectNavigationController { navigationController in
                    let navigationBar = navigationController.navigationBar
                    navigationBar.barTintColor = UIColor(Colors.systemBackground)
                    let navigationBarAppearance = UINavigationBarAppearance()
                    navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)
                    navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
                    navigationBar.standardAppearance = navigationBarAppearance
                }
                .onAppear {
                    originalBrightness = UIScreen.main.brightness
                    viewStore.send(.loadMatrixCodeImage(screenSize: UIScreen.main.bounds.size))
                }
                .onDisappear {
                    if let originalBrightness = originalBrightness {
                        UIScreen.main.brightness = originalBrightness
                    }
                }
            }
        }
        .accentColor(Colors.primary700)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    struct TitleView: View {
        var body: some View {
            VStack(spacing: 8) {
                Text(L10n.pucTxtTitle)
                    .foregroundColor(Colors.systemLabel)
                    .font(Font.title.bold())
                    .accessibility(identifier: A11y.messages.pickupCode.pucTxtTitle)

                Text(L10n.pucTxtSubtitle)
                    .font(Font.subheadline.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .accessibility(identifier: A11y.messages.pickupCode.pucTxtSubtitle)
            }
        }
    }

    struct HRCodeView: View {
        let code: String
        var body: some View {
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    Text(code)
                        .font(Font.title3.bold())
                    Text(L10n.pucTxtTitle)
                        .foregroundColor(Colors.systemLabelSecondary)
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding()

                Spacer()
            }
            .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Colors.systemBackgroundSecondary))
            .padding()

            .accessibility(identifier: A11y.messages.pickupCode.pucTxtHrCode)
        }
    }

    struct DMCView: View {
        let image: UIImage
        let dmcCode: String
        var body: some View {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .background(Colors.systemColorWhite)
                Text(dmcCode)
                    .font(.subheadline)
                    .foregroundColor(Colors.systemLabelSecondary)
            }
        }
    }
}

struct PickupCodeView_Previews: PreviewProvider {
    static var previews: some View {
        PickupCodeView(store: PickupCodeDomain.Dummies.store)
    }
}
