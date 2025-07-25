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

import Combine
import ComposableArchitecture
import eRpKit
import eRpStyleKit
import SwiftUI

struct HealthCardPasswordReadCardView: View {
    @Perception.Bindable var store: StoreOf<HealthCardPasswordReadCardDomain>

    static let height: CGFloat = {
        // Compensate display scaling (Settings -> Display & Brightness -> Display -> Standard vs. Zoomed
        180 * UIScreen.main.scale / UIScreen.main.nativeScale
    }()

    var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                // Use overlay to also fill safe area but specify fixed height

                VStack {}
                    .frame(width: nil, height: Self.height, alignment: .top)
                    .overlay(
                        HStack {
                            Image(asset: Asset.CardWall.onScreenEgk)
                                .scaledToFill()
                                .frame(width: nil, height: Self.height, alignment: .bottom)
                        }
                    )

                Line()
                    .stroke(style: StrokeStyle(lineWidth: 2,
                                               lineCap: CoreGraphics.CGLineCap.round,
                                               lineJoin: CoreGraphics.CGLineJoin.round,
                                               miterLimit: 2,
                                               dash: [8, 8],
                                               dashPhase: 0))
                    .foregroundColor(Color(.opaqueSeparator))
                    .frame(width: nil, height: 2, alignment: .center)

                Text(L10n.cdwTxtRcPlacement)
                    .font(.subheadline.bold())
                    .foregroundColor(Color(.secondaryLabel))
                    .padding(8)
                    .padding(.bottom, 16)

                Text(L10n.cdwTxtRcCta)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding()

                Spacer(minLength: 0)

                GreyDivider()

                Button(
                    action: { store.send(.readCard) },
                    label: { Text(L10n.stgBtnCardResetRead) }
                )
                .buttonStyle(eRpStyleKit.PrimaryButtonStyle(enabled: true, destructive: false))
                .accessibility(identifier: A11y.settings.card.stgBtnCardResetRead)
                .padding(.horizontal)
                .padding(.vertical, 8)

                Button(
                    action: { store.send(.backButtonTapped) },
                    label: { Label(title: { Text(L10n.cdwBtnRcBack) }, icon: {}) }
                )
                .buttonStyle(.secondary)
                .padding(.horizontal)
            }
            .alert($store.scope(state: \.destination?.alert?.alert, action: \.destination.alert))
            .keyboardShortcut(.defaultAction) // workaround: this makes the alert's primary button bold
            .navigationBarHidden(true)
            .statusBar(hidden: true)
        }
    }

    struct Line: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.height * 0.5))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.5))
            return path
        }
    }
}

struct HealthCardPasswordReadCardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HealthCardPasswordReadCardView(
                store: HealthCardPasswordReadCardDomain.Dummies.store
            )
        }
    }
}
