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

struct ColoredToggleStyle: ToggleStyle {
    var onColor = Color(UIColor.green)
    var offColor = Color(UIColor.clear)
    var thumbColor = Color.white

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            configuration.label // The text (or view) portion of the Toggle
            Spacer()
            RoundedRectangle(cornerRadius: 15, style: .circular)
                .fill(configuration.isOn ? onColor : offColor)
                .frame(width: 50, height: 30)
                .padding(2)
                .overlay(
                    RoundedRectangle(cornerRadius: 17).stroke(Color.white, lineWidth: 1)
                )
                .overlay(
                    Circle()
                        .fill(thumbColor)
                        .padding(2)
                        .offset(x: configuration.isOn ? 10 : -10)
                )
                .animation(Animation.easeInOut(duration: 0.2))
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}
