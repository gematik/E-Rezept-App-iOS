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

import eRpStyleKit
import SwiftUI

struct VersionInfoView: View {
    let marketingVersion: String
    let buildNumber: String
    let buildHash: String

    init(appVersion: AppVersion) {
        marketingVersion = appVersion.productVersion
        buildNumber = appVersion.buildNumber
        buildHash = appVersion.buildHash
    }

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Spacer(minLength: 32)
            HStack(spacing: 4) {
                Image(systemName: SFSymbolName.flipPhone)
                Text(L10n.stgTxtVersionAndBuild(marketingVersion, buildNumber))
            }
            HStack(spacing: 4) {
                Image(systemName: SFSymbolName.phoneSquare)
                Text(buildHash)
            }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .font(.subheadline)
        .foregroundColor(Color(.secondaryLabel))
    }
}

struct VersionInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VersionInfoView(
            appVersion: AppVersion(productVersion: "1.0", buildNumber: "LOCAL BUILD", buildHash: "LOCAL BUILD")
        )
    }
}
