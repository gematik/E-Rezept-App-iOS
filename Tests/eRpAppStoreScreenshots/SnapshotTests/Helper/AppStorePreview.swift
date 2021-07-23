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

// The following is heavily inspired by https://github.com/pointfreeco/isowords ❤️

import SnapshotTesting
import SwiftUI

struct Snapshot<Content>: View where Content: View {
    private let content: () -> Content
    @State private var image: Image?
    private let snapshotting: Snapshotting<AnyView, UIImage>

    init(_ snapshotting: Snapshotting<AnyView, UIImage>,
         @ViewBuilder
         _ content: @escaping () -> Content) {
        self.content = content
        self.snapshotting = snapshotting
    }

    var body: some View {
        ZStack {
            self.image?
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .onAppear {
            self.snapshotting
                .snapshot(AnyView(self.content()))
                .run { self.image = Image(uiImage: $0) }
        }
    }
}

struct AppStorePreview<SnapshotContent: View>: View {
    private let backgroundColor: Color
    @Environment(\.colorScheme) var colorScheme
    private let snapshotContent: () -> SnapshotContent
    private let snapshotting: Snapshotting<AnyView, UIImage>

    init(
        _ snapshotting: Snapshotting<AnyView, UIImage>,
        backgroundColor: Color,
        @ViewBuilder
        _ snapshotContent: @escaping () -> SnapshotContent
    ) {
        self.backgroundColor = backgroundColor
        self.snapshotContent = snapshotContent
        self.snapshotting = snapshotting
    }

    var body: some View {
        ZStack {
            Group {
                Snapshot(self.snapshotting) {
                    ZStack(alignment: .top) {
                        self.snapshotContent()

                        StatusBar()
                    }
                }
            }
            .cornerRadius(10)
            .clipped()
            .background(Color.black)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(self.backgroundColor.ignoresSafeArea())
        .ignoresSafeArea()
    }
}

struct StatusBar: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                Text("9:41")
                Spacer()
                Text("\(Image(systemName: "wifi")) \(Image(systemName: "battery.100"))")
            }
            .font(Font.system(size: 14).monospacedDigit().bold())
            .foregroundColor(self.colorScheme == .dark ? .white : .black)
            .padding(.top, 2)
            .padding(.leading, 6)
            .padding(.trailing, 3)

            Notch()
                .fill(Color.black)
                .frame(height: 25)
        }
        .ignoresSafeArea()
    }
}

struct Notch: Shape {
  func path(in rect: CGRect) -> Path {
    Path {
      let notchInset = rect.size.width * 0.23
      let smallNotchRadius: CGFloat = 7
      let scaleFactor: CGFloat = 1.6
      let notchRadius = rect.maxY / scaleFactor

      $0.move(to: .init(x: 0, y: 0))
      $0.addLine(to: .init(x: notchInset, y: 0))
      $0.addArc(
          center: .init(x: notchInset - smallNotchRadius, y: smallNotchRadius),
          radius: smallNotchRadius,
          startAngle: .init(degrees: -90),
          endAngle: .init(degrees: 0),
          clockwise: false
      )
      $0.addArc(
          center: .init(x: notchInset + notchRadius, y: notchRadius * (scaleFactor - 1)),
          radius: notchRadius,
          startAngle: .init(degrees: 180),
          endAngle: .init(degrees: 90),
          clockwise: true
      )
      $0.addLine(to: .init(x: rect.width - notchInset - notchRadius, y: rect.height))
      $0.addArc(
          center: .init(x: rect.width - notchInset - notchRadius, y: notchRadius * (scaleFactor - 1)),
          radius: notchRadius,
          startAngle: .init(degrees: 90),
          endAngle: .init(degrees: 0),
          clockwise: true
      )
      $0.addLine(to: .init(x: rect.width - notchInset, y: 0))
      $0.addArc(
          center: .init(x: rect.width - notchInset + smallNotchRadius, y: smallNotchRadius),
          radius: smallNotchRadius,
          startAngle: .init(degrees: 180),
          endAngle: .init(degrees: 270),
          clockwise: false
      )
      $0.addLine(to: .init(x: rect.width, y: 0))
      $0.closeSubpath()
    }
  }
}
