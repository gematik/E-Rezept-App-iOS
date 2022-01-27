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

import SwiftUI

struct ProfileCell: View {
    let profile: ProfileCellModel

    let isSelected: Bool
    let showAsNavigationLink: Bool

    init(profile: ProfileCellModel, isSelected: Bool, showAsNavigationLink: Bool = false) {
        self.profile = profile
        self.isSelected = isSelected
        self.showAsNavigationLink = showAsNavigationLink
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Circle()
                .strokeBorder(profile.color.border, lineWidth: isSelected ? 2 : 0)
                .frame(width: 32, height: 32, alignment: .center)
                .background(Circle().fill(profile.color.background))
                .overlay(
                    Text(profile.emoji ?? profile.acronym)
                        .font(.system(size: 13))
                )
                .overlay(ConnectionStatusCircle(status: profile.connectionStatus),
                         alignment: .bottomTrailing)

            VStack(alignment: .leading, spacing: 0) {
                Text(profile.name)
                    .foregroundColor(Color(.label))
                    .font(.body)

                if let date = profile.lastSuccessfulSync {
                    RelativeTimerView(date: date)
                        .foregroundColor(Color(.secondaryLabel))
                        .font(.caption)
                } else {
                    Text(L10n.ctlTxtProfileCellNotConnected)
                        .foregroundColor(Color(.secondaryLabel))
                        .font(.caption)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)

            if showAsNavigationLink {
                Image(systemName: SFSymbolName.chevronForward)
                    .foregroundColor(Color(.tertiaryLabel))
                    .font(.body.weight(.semibold))
            }
        }
        .padding(.vertical, 8)
    }

    struct ConnectionStatusCircle: View {
        let status: ProfileConnectionStatus?

        var body: some View {
            if let status = status {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 12, height: 12)
                    .overlay(Circle()
                        .fill(status == .connected ? Colors.secondary600 : Colors.red600)
                        .frame(width: 8, height: 8))
            }
        }
    }
}

protocol ProfileCellModel {
    var name: String { get }
    var acronym: String { get }
    var emoji: String? { get }
    var color: ProfileColor { get }
    var connectionStatus: ProfileConnectionStatus? { get }
    var lastSuccessfulSync: Date? { get }
}

struct ProfileCell_PreviewProvider: PreviewProvider {
    static var previews: some View {
        List {
            ProfileCell(
                profile: UserProfile.Dummies.profileA,
                isSelected: true,
                showAsNavigationLink: true
            )
            ProfileCell(
                profile: UserProfile.Dummies.profileB,
                isSelected: false
            )
            ProfileCell(
                profile: UserProfile.Dummies.profileC,
                isSelected: false,
                showAsNavigationLink: true
            )
        }
        .listStyle(InsetGroupedListStyle())
    }
}
