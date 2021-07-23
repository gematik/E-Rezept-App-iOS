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

import ComposableArchitecture
import eRpKit
import SwiftUI

struct CardWallEGKOrderHelpView: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        VStack {
            List {
                VStack {
                    Text(L10n.cdwTxtOrderEgkHeadline)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .font(Font.title.bold())
                        .accessibility(identifier: A11y.cardWall.orderEGK.cdwTxtOrderEgkHeadline)

                    Text(L10n.cdwTxtOrderEgkDesription)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .accessibility(identifier: A11y.cardWall.orderEGK.cdwTxtOrderEgkDesription)
                }

                Section(header: Text(L10n.cdwTxtOrderEgkKvSubheadline)
                            .font(Font.headline.bold())
                            .foregroundColor(Color(.label))
                            .padding(.top)) {
                    Picker(L10n.cdwTxtOrderEgkKvPlaceholder, selection: $viewModel.healthInsuranceId) {
                        ForEach(viewModel.insuranceCompanies) { insurance in
                            Text(insurance.name).tag(insurance.id)
                        }
                    }
                    .accessibility(identifier: A11y.cardWall.orderEGK.cdwInpOrderEgkKv)
                }

                Section(header: Text(L10n.cdwTxtOrderEgkKvnrSubheadline)
                            .font(Font.headline.bold())
                            .foregroundColor(Color(.label))
                            .padding(.top)) {
                    HStack {
                        TextField(L10n.cdwTxtOrderEgkKvnrPlaceholder, text: $viewModel.kvnr)
                            .font(.body)
                            .accessibility(identifier: A11y.cardWall.orderEGK.cdwInpOrderEgkKvnr)

                        if viewModel.showKVNRError {
                            if viewModel.kvnr.isValid {
                                Image(systemName: SFSymbolName.checkmark)
                                    .foregroundColor(Colors.secondary600)
                                    .font(Font.body.bold())
                            } else {
                                Image(systemName: SFSymbolName.crossIconPlain)
                                    .foregroundColor(Colors.red600)
                                    .font(Font.body.bold())
                            }
                        }
                    }
                }
            }
            .introspectTableView { tableView in
                tableView.backgroundColor = UIColor.systemBackground
                tableView.separatorStyle = .none
            }
            .listStyle(GroupedListStyle())
            .respectKeyboardInsets()

            VStack {
                GreyDivider()

                PrimaryTextButton(
                    text: L10n.cdwBtnOrderEgkSendMail,
                    a11y: A11y.cardWall.orderEGK.cdwBtnOrderEgkMail,
                    isEnabled: viewModel.valid
                ) {
                    viewModel.sendEMail()
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    class ViewModel: ObservableObject {
        let insuranceCompanies: [InsuranceCompany]

        @Published var healthInsuranceId: UUID {
            didSet {
                insuranceCompany = insuranceCompanies.first { $0.id == healthInsuranceId }
            }
        }

        var insuranceCompany: InsuranceCompany?

        @Published var kvnr: KVNR = ""

        var valid: Bool {
            insuranceCompany != nil && kvnr.isValid
        }

        var showKVNRError: Bool {
            kvnr.count >= 10
        }

        init() {
            healthInsuranceId = UUID()

            let decoder = JSONDecoder()
            guard let url = Bundle.main.url(forResource: "insurance_companies", withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let directory = try? decoder.decode(InsuranceCompaniesDirectory.self, from: data) else {
                insuranceCompanies = []
                return
            }
            insuranceCompanies = directory.entries
        }

        func sendEMail() {
            guard let insuranceCompany = insuranceCompany,
                  kvnr.isValid else {
                return
            }

            let subject = NSLocalizedString("cdw_txt_order_egk_mail_subject", comment: "")
            let bodyFormat = NSLocalizedString("cdw_txt_order_egk_mail_body", comment: "")
            let body = String(format: bodyFormat, insuranceCompany.name, kvnr)

            guard let url = createEmailUrl(to: insuranceCompany.email, subject: subject, body: body) else {
                return
            }

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }

        private func createEmailUrl(to email: String, subject: String? = nil, body: String? = nil) -> URL? {
            var urlString = URLComponents(string: "mailto:\(email)")
            var queryItems = [URLQueryItem]()

            if let subject = subject {
                queryItems.append(URLQueryItem(name: "subject", value: subject))
            }

            if let body = body {
                queryItems.append(URLQueryItem(name: "body", value: body))
            }

            urlString?.queryItems = queryItems

            return urlString?.url
        }
    }

    struct InsuranceCompaniesDirectory: Decodable {
        let entries: [InsuranceCompany]
    }

    struct InsuranceCompany: Decodable, Identifiable, Hashable {
        let id = UUID() // swiftlint:disable:this identifier_name

        let name: String
        let email: String

        enum CodingKeys: CodingKey {
            case name
            case email
        }
    }
}

struct CardWallEGKOrderHelpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CardWallEGKOrderHelpView()
        }
        .preferredColorScheme(.dark)
    }
}
