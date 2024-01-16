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

import Foundation
import SwiftUI

struct HorizontalProfileSelectionChipView: View {
    let userProfile: UserProfile
    let isSelected: Bool

    var showConnectionStatusTimeInterval = 2
    @State var showConnectionStatus = false

    var body: some View {
        HStack(alignment: .center) {
            Text(userProfile.name)
                .foregroundColor(isSelected ? Colors.systemLabel : Colors.textSecondary)
                .font(.body)

            if userProfile.activityIndicating {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.horizontal, 2)
                    .onAppear {
                        withAnimation { self.showConnectionStatus = true }
                    }
            } else {
                if showConnectionStatus {
                    Image(Self.imageAsset(for: userProfile.connectionStatus))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + DispatchTimeInterval.seconds(showConnectionStatusTimeInterval)
                            ) {
                                withAnimation { self.showConnectionStatus = false }
                            }
                        }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(isSelected ? Colors.systemGray6 : Colors.systemBackgroundTertiary)
        .border(isSelected ? Colors.separator : Colors.systemGray6, cornerRadius: 8)
        .accessibilityRemoveTraits(.isStaticText)
        .accessibilityAddTraits(.isButton)
        .accessibilityAddTraits(isSelected ? .isSelected : .isButton)
        .accessibility(identifier: A11y.profileSelection.proBtnSelectionProfileEntry)
    }

    static func imageAsset(for profileConnectionStatus: ProfileConnectionStatus) -> ImageAsset {
        switch profileConnectionStatus {
        case .connected: return Asset.Main.checkmarkCloudGreen
        case .disconnected: return Asset.Main.cloudSlashGrey
        case .never: return Asset.Main.cloudSlashGrey
        }
    }
}

// swiftlint:disable:next type_name
struct HorizontalProfileSelectionChipView_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            HorizontalProfileSelectionChipView(
                userProfile: UserProfile.Dummies.profileD,
                isSelected: true
            )

            HorizontalProfileSelectionChipView(
                userProfile: UserProfile.Dummies.profileA,
                isSelected: false,
                showConnectionStatusTimeInterval: 1000,
                showConnectionStatus: true
            )

            HorizontalProfileSelectionChipView(
                userProfile: UserProfile.Dummies.profileB,
                isSelected: false,
                showConnectionStatusTimeInterval: 1000,
                showConnectionStatus: true
            )

            HorizontalProfileSelectionChipView(
                userProfile: UserProfile.Dummies.profileC,
                isSelected: false
            )
        }
    }
}
