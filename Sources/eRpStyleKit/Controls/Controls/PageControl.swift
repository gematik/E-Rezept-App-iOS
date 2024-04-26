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
                    .frame(width: 8)
                    .foregroundColor(page == currentPage ? Colors.primary500 : Colors.systemGray5)
                    .scaleEffect(
                        page == currentPage ? CGSize(width: 1.2, height: 1.2) : CGSize(width: 1.0, height: 1.0),
                        anchor: .center
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Colors.systemGray6)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
        .animation(.bouncy, value: numberOfPages)
        .animation(.easeInOut(duration: 0.2), value: currentPage)
        .accessibilityHidden(true)
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
