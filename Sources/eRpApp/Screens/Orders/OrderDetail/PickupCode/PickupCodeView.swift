//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import ComposableArchitecture
import eRpStyleKit
import Perception
import SwiftUI
import SwiftUIIntrospect

struct PickupCodeView: View {
    @Perception.Bindable var store: StoreOf<PickupCodeDomain>
    @State var originalBrightness: CGFloat?

    init(store: StoreOf<PickupCodeDomain>) {
        self.store = store
    }

    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 0) {
                        if let dmcCode = store.pickupCodeDMC {
                            DMCView(image: store.dmcImage, dmcCode: dmcCode)
                                .padding(.horizontal, 8)
                                .padding(.vertical)
                        }

                        if let hrCode = store.pickupCodeHR {
                            HRCodeView(code: hrCode)
                                .padding(.vertical, 8)
                        }

                        TitleView(store: store)
                    }
                }
                .navigationBarItems(trailing: CloseButton { store.send(.delegate(.close)) }
                    .accessibilityIdentifier(A11y.orderDetail.pickupCode.pucBtnClose))
                .navigationBarTitleDisplayMode(.inline)
                .introspect(.navigationView(style: .stack), on: .iOS(.v15, .v16, .v17, .v18)) { navigationController in
                    let navigationBar = navigationController.navigationBar
                    navigationBar.barTintColor = UIColor(Colors.systemBackground)
                    let navigationBarAppearance = UINavigationBarAppearance()
                    navigationBarAppearance.shadowColor = UIColor(Colors.systemColorClear)
                    navigationBarAppearance.backgroundColor = UIColor(Colors.systemBackground)
                    navigationBar.standardAppearance = navigationBarAppearance
                }
                .task {
                    await store.send(.loadMatrixCodeImage(screenSize: UIScreen.main.bounds.size)).finish()
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
            .tint(Colors.primary700)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    struct TitleView: View {
        @Perception.Bindable var store: StoreOf<PickupCodeDomain>

        var body: some View {
            WithPerceptionTracking {
                VStack(spacing: 8) {
                    Text(L10n.pucTxtTitle)
                        .foregroundColor(Colors.systemLabel)
                        .font(Font.subheadline.weight(.semibold))
                        .accessibility(identifier: A11y.orderDetail.pickupCode.pucTxtTitle)

                    let name = store.pharmacyName ?? L10n.ordTxtNoPharmacyName.text
                    Text(L10n.pucTxtSubtitle(name))
                        .foregroundColor(Colors.systemLabelSecondary)
                        .font(Font.subheadline)
                        .multilineTextAlignment(.center)
                        .accessibility(identifier: A11y.orderDetail.pickupCode.pucTxtSubtitle)
                }
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
