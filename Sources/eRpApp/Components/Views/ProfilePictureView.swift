//
//  Copyright (c) 2023 gematik GmbH
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

struct ProfilePictureView: View {
    let text: String?
    let image: ProfilePicture?
    let color: Color?
    let connection: ProfileConnectionStatus?
    let style: ProfilePictureView.Style
    let action: () -> Void

    enum Style {
        case xxLarge
        case large
        case small

        var size: CGFloat {
            switch self {
            case .xxLarge: return 152
            case .large: return 96
            case .small: return 40
            }
        }

        var imageSize: CGFloat {
            switch self {
            case .xxLarge: return 108
            case .large: return 54
            case .small: return 20
            }
        }

        var paddingLeading: CGFloat {
            switch self {
            case .xxLarge: return 16
            case .large: return 16
            case .small: return 0
            }
        }

        var statusSize: CGFloat {
            switch self {
            case .xxLarge: return 52
            case .large: return 40
            case .small: return 28
            }
        }

        var statusImageSize: CGFloat {
            switch self {
            case .xxLarge: return 20
            case .large: return 16
            case .small: return 12
            }
        }

        var textSize: CGFloat {
            switch self {
            case .xxLarge: return 33
            case .large: return 22
            case .small: return 11
            }
        }
    }

    var connectionStatusImage: Image? {
        switch connection {
        case .none, .never:
            return nil
        case .connected:
            return Image(systemName: SFSymbolName.checkmark)
        case .disconnected:
            return Image(systemName: SFSymbolName.cross)
        }
    }

    var body: some View {
        Button {
            action()
        } label: {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let image = image?.description, !image.name.isEmpty {
                        Image(image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    } else {
                        Text(text ?? "")
                            .font(.system(size: style.textSize).weight(.bold))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
                .frame(width: style.size, height: style.size, alignment: .center)
                .background(Circle().fill(color ?? Colors.secondary))
                .foregroundColor(Color(.secondaryLabel))
                .padding(.vertical, 8)
                .padding(.trailing, 16)
                .padding(.leading, style.paddingLeading)
                .accessibilityIdentifier(A11y.mainScreen.erxBtnProfile)

                if let connectionStatusImage {
                    let isConnected = connection == .connected
                    connectionStatusImage
                        .font(.system(size: style.statusImageSize).weight(.bold))
                        .frame(width: style.statusSize, height: style.statusSize, alignment: .center)
                        .foregroundColor(isConnected ? Colors.secondary600 : Colors.systemGray)
                        .background(Circle().fill(isConnected ? Colors.secondary200 : Colors.secondary))
                        .border(Colors.systemBackground, width: 4, cornerRadius: 999)
                        .accessibilityIdentifier(A11y.mainScreen.erxImgProfileStatus)
                        .accessibilityLabel(isConnected ? L10n.mainTxtProfileStatusOnline : L10n
                            .mainTxtProfileStatusOffline)
                }
            }
        }
    }
}

struct ProfilePictureView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            ProfilePictureView(
                text: "SD",
                image: ProfilePicture.none,
                color: .blue,
                connection: .connected,
                style: .small
            ) {}
            ProfilePictureView(
                text: "LN",
                image: .baby,
                color: .green,
                connection: .disconnected,
                style: .large
            ) {}
            ProfilePictureView(
                text: "FM",
                image: .doctor,
                color: .yellow,
                connection: .never,
                style: .large
            ) {}
        }
        .background(Color.red)
    }
}
