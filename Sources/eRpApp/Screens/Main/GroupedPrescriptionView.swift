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

struct GroupedPrescriptionView: View {
    let groupedPrescription: GroupedPrescription
    let store: GroupedPrescriptionListDomain.Store
    @ScaledMetric var lastItemSpacerSize: CGFloat = 12

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                if groupedPrescription.displayType == .lowDetail {
                    LowDetailHeaderView(
                        text: groupedPrescription.title,
                        date: groupedPrescription.authoredOn
                    )
                    .padding()
                    .layoutPriority(1)
                } else {
                    FullDetailHeaderView(
                        text: groupedPrescription.title,
                        date: groupedPrescription.authoredOn
                    )
                    .padding()
                    .layoutPriority(1)
                }
                ForEach(groupedPrescription.prescriptions.indices, id: \.self) { index in
                    let prescription = groupedPrescription.prescriptions[index]
                    if groupedPrescription.displayType == .lowDetail {
                        LowDetailCellView(prescription: prescription) {
                            viewStore.send(.prescriptionDetailViewTapped(selectedPrescription: prescription))
                        }
                        .padding(.horizontal)
                    } else {
                        FullDetailCellView(prescription: prescription) {
                            viewStore.send(.prescriptionDetailViewTapped(selectedPrescription: prescription))
                        }
                        .padding(.horizontal)
                    }

                    if index == groupedPrescription.prescriptions.count - 1 {
                        Spacer()
                            .frame(height: lastItemSpacerSize)
                    } else {
                        Divider()
                            .padding(.leading)
                            .padding(.top, 11.5)
                            .padding(.bottom, 12)
                    }
                }
                if !groupedPrescription.isRedeemed {
                    FooterView {
                        viewStore.send(.redeemViewTapped(selectedGroupedPrescription: groupedPrescription))
                    }
                    .padding(.top)
                }
            }
        }
        .background(Color(.tertiarySystemBackground))
        .border(Color(.opaqueSeparator), width: 0.5, cornerRadius: 16)
        .shadow(color: Color.black.opacity(0.08), radius: 8)
        .accessibility(identifier: A18n.mainScreen.erxDetailedBlock)
    }

    struct FullDetailHeaderView: View {
        let text: String
        let date: String?
        private var dateFormatted: String {
            if let date = date, let dateFhirFormatted =
                AppContainer.shared.fhirDateFormatter.date(from: date, format: .yearMonthDay) {
                return AppContainer.shared.uiDateFormatter.string(from: dateFhirFormatted)
            }
            return ""
        }

        var body: some View {
            HStack(alignment: .top) {
                Text(text)
                    .font(Font.subheadline.weight(.semibold))
                    .multilineTextAlignment(.leading)

                Spacer()
                Text(dateFormatted)
                    .font(.footnote)
            }
            .foregroundColor(Color(.secondaryLabel))
        }
    }

    struct LowDetailHeaderView: View {
        let text: String
        let date: String?
        private var dateFormatted: String {
            if let date = date, let dateFhirFormatted =
                AppContainer.shared.fhirDateFormatter.date(from: date, format: .yearMonthDay) {
                return AppContainer.shared.uiDateFormatter.string(from: dateFhirFormatted)
            }
            return ""
        }

        var body: some View {
            HStack(alignment: .top) {
                Text(text)
                    .font(Font.subheadline.weight(.semibold))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Colors.primary600)
                Image(systemName: SFSymbolName.pencil)
                    .font(Font.subheadline.weight(.semibold))
                    .foregroundColor(Colors.primary600)
                Spacer()
                Text(dateFormatted)
                    .font(.footnote)
            }
            .foregroundColor(Color(.secondaryLabel))
        }
    }

    struct FullDetailCellView: View {
        var prescription: ErxTask
        let action: () -> Void
        @State var showDetail = false

        private var remainingDays: Int {
            guard let expiresOnString = prescription.expiresOn,
                let expiresDate = AppContainer.shared.fhirDateFormatter.date(
                    from: expiresOnString,
                    format: .yearMonthDay
                ),
                let remainingDays = Date().days(until: expiresDate) else {
                return 0
            }
            return max(remainingDays, 0)
        }

        private var localizedString: String {
            let formatString: String = NSLocalizedString(
                "erx_txt_expires_in",
                comment: "erx_txt_expires_in string format to be found in Localized.stringsdict"
            )
            return String.localizedStringWithFormat(formatString, remainingDays)
        }

        var body: some View {
            Button(
                action: {
                    action()
                },
                label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(prescription.medication?.name, placeholder: L10n.erxTxtMedicationPlaceholder)
                                .foregroundColor(Colors.systemLabel)
                                .font(Font.body.weight(.semibold))
                            Text(localizedString)
                                .font(Font.subheadline.weight(.regular))
                                .foregroundColor(Color(.secondaryLabel))
                        }
                        Spacer()
                        Image(systemName: SFSymbolName.rightDisclosureIndicator)
                            .font(Font.headline.weight(.semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                }
            ).buttonStyle(DefaultButtonStyle())
        }
    }

    struct LowDetailCellView: View {
        let prescription: ErxTask
        let action: () -> Void
        @State var showDetail = false

        var body: some View {
            Button(
                action: {
                    action()
                }, label: {
                    HStack {
                        Image(systemName: SFSymbolName.qrCode)
                            .font(Font.body.weight(.semibold))
                            .foregroundColor(Colors.primary500)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(prescription.medication?.name, placeholder: L10n.erxTxtMedicationPlaceholder)
                                .font(Font.body.weight(.semibold))
                        }
                        Spacer()
                        Image(systemName: SFSymbolName.rightDisclosureIndicator)
                            .font(Font.headline.weight(.semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .padding(.vertical, 8)
                }
            ).buttonStyle(PlainButtonStyle())
        }
    }

    struct FooterView: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Text(L10n.erxBtnRedeem)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .font(Font.body.weight(.semibold))
                    .foregroundColor(Colors.primary)
                    .background(Color(.quaternarySystemFill))
            }
        }
    }
}

struct RezeptBlock_Previews: PreviewProvider {
    static let groupedPrescription: GroupedPrescription = {
        GroupedPrescription.Dummies.twoPrescriptions
    }()

    static let scannedGroupedPrescription: GroupedPrescription = {
        GroupedPrescription.Dummies.twoScannedPrescriptions
    }()

    static var previews: some View {
        Group {
            GroupedPrescriptionView(
                groupedPrescription: groupedPrescription,
                store: GroupedPrescriptionListDomain.Dummies.store
            )
            .preferredColorScheme(.light)
            .previewLayout(.fixed(width: 500.0, height: 300.0))
            .padding()
            GroupedPrescriptionView(
                groupedPrescription: groupedPrescription,
                store: GroupedPrescriptionListDomain.Dummies.store
            )
            .previewLayout(.sizeThatFits)
            .padding()
            GroupedPrescriptionView(
                groupedPrescription: groupedPrescription,
                store: GroupedPrescriptionListDomain.Dummies.store
            )
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .extraExtraExtraLarge)
            .previewLayout(.sizeThatFits)
            .padding()
            GroupedPrescriptionView(
                groupedPrescription: groupedPrescription,
                store: GroupedPrescriptionListDomain.Dummies.store
            )
            .preferredColorScheme(.light)
            .previewLayout(.fixed(width: 500.0, height: 300.0))
            .padding()
            GroupedPrescriptionView(
                groupedPrescription: groupedPrescription,
                store: GroupedPrescriptionListDomain.Dummies.store
            )
            .previewLayout(.sizeThatFits)
            .padding()
            GroupedPrescriptionView(
                groupedPrescription: groupedPrescription,
                store: GroupedPrescriptionListDomain.Dummies.store
            )
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .extraExtraExtraLarge)
            .previewLayout(.sizeThatFits)
            .padding()
        }
    }
}
