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

/// sourcery: StringAssetInitialized
struct ProgressTile: View {
    let icon: String
    var title: LocalizedStringKey
    var description: String?
    let state: State

    var body: some View {
        HStack(spacing: 16) {
            HStack(alignment: .top, spacing: 0) {
                Image(systemName: icon)
                    .frame(minWidth: 24, minHeight: 24)
                    .foregroundColor(textColor)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(errorText, placeholder: title)
                        .font(Font.body.weight(.semibold))
                        .foregroundColor(textColor)
                    if let description = descriptionText {
                        Text(description)
                            .font(Font.subheadline)
                            .foregroundColor(textColor)
                    }
                }
                .padding(.leading, 16)

                Spacer()
            }
            .padding(0)

            switch state {
            case .loading:
                ProgressView()
                    .frame(width: 24, height: 24)
            case .idle, .error, .done:
                Image(systemName: iconName)
                    .font(.title3)
                    .frame(minWidth: 24, minHeight: 24)
                    .foregroundColor(iconColor)
                    .hidden(state == .idle)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(backgroundColor))
        .border(borderColor, width: 0.5, cornerRadius: 16)
    }

    enum State: Equatable {
        case idle
        case loading
        case done
        case error(title: String, description: String?)
    }

    private var errorText: String? {
        if case let .error(title, _) = state {
            return title
        }
        return nil
    }

    private var descriptionText: String? {
        if case let .error(_, description) = state {
            return description
        }
        return nil
    }

    private var textColor: Color {
        switch state {
        case .idle:
            return Colors.systemLabelSecondary
        case .loading, .done:
            return Colors.systemLabel
        case .error(title: _, description: _):
            return Colors.red900
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .idle, .loading, .done:
            return Colors.backgroundNeutral
        case .error(title: _, description: _):
            return Colors.red100
        }
    }

    private var borderColor: Color {
        switch state {
        case .idle, .loading, .done:
            return Colors.separator
        case .error(title: _, description: _):
            return Colors.red300
        }
    }

    private var iconColor: Color {
        switch state {
        case .idle, .loading, .done:
            return Colors.alertPositiv
        case .error(title: _, description: _):
            return Colors.red900
        }
    }

    private var iconName: String {
        switch state {
        case .idle, .loading, .done:
            return SFSymbolName.checkmarkCircleFill
        case .error(title: _, description: _):
            return SFSymbolName.xmarkCircleFill
        }
    }
}

struct ProgressTile_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 16) {
                ProgressTile(icon: SFSymbolName.numbers1circle,
                             title: "Verbindung mit dem Server herstellen",
                             state: .done)
                ProgressTile(icon: SFSymbolName.numbers2circle,
                             title: "Verbindung mit dem Server herstellen",
                             state: ProgressTile.State.loading)
                ProgressTile(icon: SFSymbolName.numbers3circle,
                             title: "Verbindung mit dem Server herstellen",
                             state: ProgressTile.State.idle)
                ProgressTile(icon: SFSymbolName.numbers3circle,
                             title: "Verbindung mit dem Server herstellen",
                             description: "Überprüfen Sie Ihre Verbindung mit dem Internet und starten Sie den " +
                                 "Vorgang erneut.",
                             state: ProgressTile.State.error(
                                 title: "Verbindung mit dem Server herstellen",
                                 description: "Überprüfen Sie Ihre Verbindung mit dem Internet und starten Sie den " +
                                     "Vorgang erneut."
                             ))
                Spacer()
            }
            .padding()
            .previewLayout(.fixed(width: 320, height: 500.0))

            VStack(spacing: 16) {
                ProgressTile(icon: SFSymbolName.numbers1circle,
                             title: "Verbindung mit dem Server herstellen",
                             state: .done)
                ProgressTile(icon: SFSymbolName.numbers2circle,
                             title: "Verbindung mit dem Server herstellen",
                             state: ProgressTile.State.loading)
                ProgressTile(icon: SFSymbolName.numbers3circle,
                             title: "Verbindung mit dem Server herstellen",
                             state: ProgressTile.State.idle)
                ProgressTile(icon: SFSymbolName.numbers3circle,
                             title: "Verbindung mit dem Server herstellen",
                             description: "Überprüfen Sie Ihre Verbindung mit dem Internet und starten Sie den " +
                                 "Vorgang erneut.",
                             state: ProgressTile.State.error(
                                 title: "Titel des Fehlers",
                                 description: "Überprüfen Sie Ihre Verbindung mit dem Internet und starten Sie den " +
                                     "Vorgang erneut."
                             ))
                Spacer()
            }
            .preferredColorScheme(.dark)
            .padding()
            .previewLayout(.fixed(width: 320, height: 500.0))

            VStack(spacing: 16) {
                ProgressTile(icon: SFSymbolName.numbers1circle,
                             title: "Verbindung mit dem Server herstellen",
                             state: .done)
                ProgressTile(icon: SFSymbolName.numbers2circle,
                             title: "Verbindung mit dem Server herstellen",
                             state: ProgressTile.State.loading)
                ProgressTile(icon: SFSymbolName.numbers3circle,
                             title: "Verbindung mit dem Server herstellen",
                             state: ProgressTile.State.idle)
                ProgressTile(icon: SFSymbolName.numbers3circle,
                             title: "Verbindung mit dem Server herstellen",
                             description: "Überprüfen Sie Ihre Verbindung mit dem Internet und starten Sie den " +
                                 "Vorgang erneut.",
                             state: ProgressTile.State.error(
                                 title: "Titel des Fehlers",
                                 description: "Überprüfen Sie Ihre Verbindung mit dem Internet und starten Sie den " +
                                     "Vorgang erneut."
                             ))
                Spacer()
            }
            .environment(\.sizeCategory, .extraExtraExtraLarge)
            .padding()
            .previewLayout(.fixed(width: 320, height: 700.0))
        }
    }
}
