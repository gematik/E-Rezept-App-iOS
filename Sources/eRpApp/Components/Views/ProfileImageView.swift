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
import Foundation
import SwiftUI

public struct ProfileImageView: View {
    public init(
        userImageData: Data?,
        image: ProfilePicture?,
        backgroundColor: Color,
        statusColor: Color? = nil,
        borderColor: Color? = nil,
        size: Size = .regular
    ) {
        self.userImageData = userImageData
        self.image = image
        self.backgroundColor = backgroundColor
        self.statusColor = statusColor
        self.borderColor = borderColor
        self.size = size
    }

    let userImageData: Data?
    let image: ProfilePicture?
    let backgroundColor: Color
    let statusColor: Color?
    let borderColor: Color?
    let size: Size

    public enum Size {
        case regular
        case large
        case extraLarge

        var dimension: CGFloat {
            switch self {
            case .regular: return 22
            case .large: return 32
            case .extraLarge: return 40
            }
        }
    }

    public var body: some View {
        ZStack {
            Group {
                if let userImageData = userImageData, !userImageData.isEmpty {
                    Image(uiImage: UIImage(data: userImageData) ?? UIImage())
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                } else {
                    Image(systemName: SFSymbolName.camera)
                        .font(Font.headline.weight(.bold))
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
        }
        .frame(width: size.dimension, height: size.dimension, alignment: .center)
        .background(Circle().fill(backgroundColor))
        .overlay(ConnectionStatusCircle(statusColor: statusColor),
                 alignment: .bottomTrailing)
        .frame(width: 22, height: 22, alignment: .center)
    }

    struct ConnectionStatusCircle: View {
        let statusColor: Color?

        var body: some View {
            if let statusColor = statusColor {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 12, height: 12)
                    .overlay(Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8))
            }
        }
    }
}

struct ProfileImageView_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            ProfileImageView(userImageData: nil, image: nil, backgroundColor: Color.red)

            ProfileImageView(
                userImageData: nil,
                image: ProfilePicture.none,
                backgroundColor: Color.green,
                statusColor: Color.red,
                borderColor: Color.blue,
                size: .large
            )

            ProfileImageView(
                userImageData: nil,
                image: .boyWithCard,
                backgroundColor: Color.gray,
                statusColor: Color.red,
                borderColor: Color.black,
                size: .extraLarge
            )
        }
    }
}
