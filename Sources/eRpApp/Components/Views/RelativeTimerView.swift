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

import Combine
import SwiftUI

struct RelativeTimerView: View {
    let date: Date

    @State
    private var formattedString: String?

    var body: some View {
        RelativeTimerViewForToolbars(date: date, formattedString: $formattedString)
    }
}

struct RelativeTimerViewForToolbars: View {
    let date: Date

    @Binding
    var formattedString: String?

    private let timer = Timer
        .publish(every: 60, on: .main, in: .common)
        .autoconnect()
        .merge(with: Just(Date()))
    private let formatter: RelativeDateTimeFormatter = {
        let dateFormatter = RelativeDateTimeFormatter()
        dateFormatter.unitsStyle = .short
        dateFormatter.formattingContext = .middleOfSentence
        return dateFormatter
    }()

    var body: some View {
        Group {
            if let formattedString = formattedString {
                Text(L10n.cpnTxtRelativeTimerViewLastUpdate(formattedString))
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }.onReceive(timer) { _ in
            if date.timeIntervalSinceNow <= -59 {
                self.formattedString = self.formatter.string(for: date)
            } else {
                self.formattedString = NSLocalizedString("cpn_txt_relative_timer_view_last_update_recent", comment: "")
            }
        }
    }
}
