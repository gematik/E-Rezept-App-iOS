//
//  Copyright (c) 2021 gematik GmbH
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
        .font(.footnote)
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
