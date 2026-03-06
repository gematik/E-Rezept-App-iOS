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

import SwiftUI

/// This struct defines a custom PageControl view that displays a set of circles representing pages with the current
/// page highlighted.
public struct PageControl: View {
    public init(numberOfPages: Int, currentPage: Binding<Int>) {
        self.numberOfPages = numberOfPages
        _currentPage = currentPage
    }

    let numberOfPages: Int
    @Binding var currentPage: Int

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< numberOfPages, id: \.self) { page in
                Circle()
                    .stroke()
                    .frame(width: 8)
                    .foregroundColor(Colors.systemLabel)
                    .overlay {
                        Circle()
                            .foregroundColor(Colors.primary)
                            .scaleEffect(
                                page == currentPage ? CGSize(width: 1.2, height: 1.2) : CGSize(width: 0.0, height: 0.0),
                                anchor: .center
                            )
                    }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .border(Colors.systemGray3, width: 1, cornerRadius: 16)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
        .animation(.bouncy, value: numberOfPages)
        .animation(.easeInOut(duration: 0.4), value: currentPage)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L10n.onbTxtProgressOf("\(currentPage + 1)", "\(numberOfPages)"))
    }
}

struct PreviewContainer: View {
    @State var page = 0
    @State var numberOfPages = 5
    var body: some View {
        Form {
            Button {
                page = max(0, page - 1)
            } label: {
                Label("Previous", systemImage: "minus")
            }
            Button {
                page = min(numberOfPages - 1, page + 1)
            } label: {
                Label("Next", systemImage: "plus")
            }
            Button {
                numberOfPages = max(0, numberOfPages - 1)
            } label: {
                Label("Less Pages", systemImage: "minus")
            }
            Button {
                numberOfPages = min(10, numberOfPages + 1)
            } label: {
                Label("More Pages", systemImage: "plus")
            }
            HStack {
                Text("\(page + 1)/\(numberOfPages)")
                Spacer()
                PageControl(numberOfPages: numberOfPages, currentPage: $page.animation())
            }
        }
    }
}

#Preview {
    PreviewContainer()
}
