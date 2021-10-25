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

struct OrderHealthCardInquiryOptionsView: View {
    let availableInquiries: [OrderHealthCardView.ServiceInquiry]
    @Binding var selectedInquiry: Int
    @Binding var show: Bool

    var body: some View {
        List {
            Section(footer: Footer()) {
                ForEach(availableInquiries) { inquiry in
                    Button(
                        action: {
                            selectedInquiry = inquiry.id
                            show = false
                        },

                        label: {
                            HStack {
                                Text(inquiry.localizedName)
                                Spacer()
                                if selectedInquiry == inquiry.id {
                                    Image(systemName: SFSymbolName.checkmark)
                                        .foregroundColor(Colors.primary)
                                }
                            }
                        }
                    )
                    .foregroundColor(Color(.label))
                }
            }
        }
        .navigationTitle(L10n.orderEgkTxtPickerServiceNavigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(GroupedListStyle())
        .introspectTableView { tableView in
            tableView.backgroundColor = UIColor.systemBackground
        }
    }

    struct Footer: View {
        var body: some View {
            VStack(spacing: 8) {
                Text(L10n.orderEgkTxtPickerServiceInfoFootnote)
                    .font(.caption)
                    .foregroundColor(Colors.systemLabelSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                TertiaryListButton(
                    text: L10n.orderEgkBtnInfoButton,
                    imageName: nil,
                    accessibilityIdentifier: A11y.orderEGK.ogkBtnEgkInfo
                ) {
                    if let url = URL(string: NSLocalizedString("order_egk_txt_info_link", comment: "")) {
                        UIApplication.shared.open(url)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}

struct OrderHealthCardInquiryOptionsView_Preview: PreviewProvider { // swiftlint:disable:this type_name
    struct Wrapper: View {
        @State var selectedInquiry: Int = -1
        @State var show = false

        var body: some View {
            OrderHealthCardInquiryOptionsView(availableInquiries: OrderHealthCardView.ServiceInquiry.allCases,
                                              selectedInquiry: $selectedInquiry,
                                              show: $show)
        }
    }

    static var previews: some View {
        NavigationView {
            Wrapper()
        }
    }
}
