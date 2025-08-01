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
import SwiftUI

struct OSDeprecationView: View {
    @Perception.Bindable var store: StoreOf<OSDeprecationDomain>

    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header with icon and title
                    HeaderSection(version: store.version)

                    // Information section
                    InformationSection()

                    Spacer()

                    // Continue button
                    Button(L10n.appChangedIosDeprecationContinueButton) {
                        store.send(.continueButtonTapped)
                    }
                    .buttonStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                }
                .padding(.top, 32)
                .padding(.bottom, 32)
            }
            .background(Colors.systemBackground)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Header Section

private struct HeaderSection: View {
    let version: String

    var body: some View {
        VStack(spacing: 16) {
            // Information icon
            VStack(alignment: .center) {
                Image(asset: Asset.Illustrations.infoLogo)
            }

            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(L10n.appChangedIosDeprecationTitle(version))
                    .font(.title.bold())
                    .padding(.horizontal)
                    .accessibilityAddTraits(.isHeader)

                // Subtitle
                Text(L10n.appChangedIosDeprecationSubtitle(version))
                    .font(.footnote)
                    .padding(.horizontal)
                    .foregroundColor(Colors.systemLabelSecondary)
            }
        }
    }
}

private struct InformationSection: View {
    var body: some View {
        VStack(spacing: 24) {
            // Section title
            VStack(alignment: .leading, spacing: 16) {
                Text(L10n.appChangedIosDeprecationWhatDoesItMean)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Bullet points
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        BulletPoint(text: L10n.appChangedIosDeprecationPoint1)
                            .font(.body)
                    }
                    HStack(alignment: .top) {
                        BulletPoint(text: L10n.appChangedIosDeprecationPoint2)
                    }
                    HStack(alignment: .top) {
                        BulletPoint(text: L10n.appChangedIosDeprecationPoint3)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct BulletPoint: View {
    let text: StringAsset

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CheckmarkView()

            Text(text)
                .font(.body)
        }
    }

    struct CheckmarkView: View {
        @ScaledMetric var iconSize: CGFloat = 24
        var body: some View {
            Image(systemName: SFSymbolName.checkmarkCircleFill)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: iconSize)
                .font(Font.title3.weight(.bold))
                .foregroundColor(Colors.secondary600)
                .padding(.top, 2)
                .padding(.trailing, 8)
                .accessibility(hidden: true)
        }
    }
}

#Preview("iOS 16 Deprecation") {
    NavigationView {
        OSDeprecationView(store: OSDeprecationDomain.Dummies.iOS16Store)
    }
}

#Preview("iOS 17 Deprecation") {
    NavigationView {
        OSDeprecationView(store: OSDeprecationDomain.Dummies.iOS17Store)
    }
}
