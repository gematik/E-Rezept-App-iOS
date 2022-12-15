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

import ComposableArchitecture
import eRpKit
import SwiftUI

struct GroupedPrescriptionView: View {
    let groupedPrescription: GroupedPrescription
    let store: PrescriptionListDomain.Store
    @ScaledMetric var lastItemSpacerSize: CGFloat = 12

    var body: some View {
        WithViewStore(store.stateless) { viewStore in
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
                VStack(spacing: 0) {
                    ForEach(groupedPrescription.prescriptions) { prescription in
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

                        if prescription == groupedPrescription.prescriptions.last {
                            Spacer()
                                .frame(height: lastItemSpacerSize)
                        } else {
                            Divider()
                                .padding(.leading)
                                .padding(.top, 11.5)
                                .padding(.bottom, 12)
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibility(identifier: A18n.mainScreen.erxDetailedBlockPrescriptions)
                if groupedPrescription.isRedeemable {
                    FooterView {
                        viewStore.send(.redeemViewTapped(selectedGroupedPrescription: groupedPrescription))
                    }
                    .padding(.top)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibility(identifier: A18n.mainScreen.erxDetailedBlock)
        }
        .background(Color(.tertiarySystemBackground))
        .border(Color(.opaqueSeparator), width: 0.5, cornerRadius: 16)
        .shadow(color: Color.black.opacity(0.08), radius: 8)
    }

    struct FullDetailHeaderView: View {
        let text: String
        let date: String?
        private var dateFormatted: String {
            if let date = date, let dateFhirFormatted =
                globals.fhirDateFormatter.date(from: date, format: .yearMonthDay) {
                return globals.uiDateFormatter.string(from: dateFhirFormatted)
            }
            return ""
        }

        var body: some View {
            HStack(alignment: .top) {
                Text(text)
                    .font(Font.subheadline.weight(.semibold))
                    .multilineTextAlignment(.leading)
                    .accessibility(identifier: A18n.mainScreen.erxDetailedBlockDoctor)

                Spacer()
                Text(dateFormatted)
                    .accessibility(identifier: A18n.mainScreen.erxDetailedBlockDate)
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
                globals.fhirDateFormatter.date(from: date, format: .yearMonthDay) {
                return globals.uiDateFormatter.string(from: dateFhirFormatted)
            }
            return ""
        }

        var body: some View {
            HStack(alignment: .top) {
                Text(text)
                    .font(Font.subheadline.weight(.semibold))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Colors.primary600)
                    .accessibility(identifier: A18n.mainScreen.erxDetailedBlockDoctor)
                Image(systemName: SFSymbolName.pencil)
                    .font(Font.subheadline.weight(.semibold))
                    .foregroundColor(Colors.primary600)
                Spacer()
                Text(dateFormatted)
                    .accessibility(identifier: A18n.mainScreen.erxDetailedBlockDate)
                    .font(.footnote)
            }
            .foregroundColor(Color(.secondaryLabel))
        }
    }

    struct FullDetailCellView: View {
        var prescription: GroupedPrescription.Prescription
        let action: () -> Void
        @State var showDetail = false

        var body: some View {
            Button(
                action: {
                    action()
                },
                label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            PrescriptionStatusView(prescription: prescription)
                                .accessibility(identifier: A18n.mainScreen.erxDetailedBlockStatus)
                            Text(prescription.prescribedMedication?.name, placeholder: L10n.erxTxtMedicationPlaceholder)
                                .foregroundColor(Colors.systemLabel)
                                .font(Font.body.weight(.semibold))
                                .multilineTextAlignment(.leading)
                                .accessibility(identifier: A18n.mainScreen.erxDetailedBlockPrescriptionName)
                            Text(prescription.statusMessage)
                                .font(Font.subheadline.weight(.regular))
                                .foregroundColor(Color(.secondaryLabel))
                                .accessibility(identifier: A18n.mainScreen.erxDetailedBlockPrescriptionValidity)
                            if let status = prescription.multiplePrescriptionStatus {
                                Text(status)
                                    .font(Font.footnote)
                                    .padding(.init(top: 2, leading: 8, bottom: 2, trailing: 8))
                                    .foregroundColor(Colors.systemLabelSecondary)
                                    .background(Colors.backgroundSecondary)
                                    .cornerRadius(8)
                                    .padding(.top, 8)
                                    .accessibility(identifier: A18n.mainScreen
                                        .erxDetailedBlockMultiplePrescriptionIndex)
                            }
                        }
                        .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: SFSymbolName.rightDisclosureIndicator)
                            .font(Font.headline.weight(.semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                }
            )
            .buttonStyle(DefaultButtonStyle())
            .accessibilityElement(children: .contain)
        }
    }

    struct LowDetailCellView: View {
        let prescription: GroupedPrescription.Prescription
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
                            PrescriptionStatusView(prescription: prescription)
                            Text(prescription.prescribedMedication?.name, placeholder: L10n.erxTxtMedicationPlaceholder)
                                .font(Font.body.weight(.semibold))
                                .foregroundColor(Colors.systemLabel)
                                .multilineTextAlignment(.leading)
                                .accessibility(identifier: A18n.mainScreen.erxDetailedBlockPrescriptionName)
                            if prescription.isArchived {
                                Text(prescription.statusMessage)
                                    .font(Font.subheadline.weight(.regular))
                                    .foregroundColor(Color(.secondaryLabel))
                            }
                        }
                        Spacer()
                        Image(systemName: SFSymbolName.rightDisclosureIndicator)
                            .font(Font.headline.weight(.semibold))
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .padding(.vertical, 8)
                }
            )
            .buttonStyle(PlainButtonStyle())
            .accessibilityElement(children: .contain)
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
                    .accessibility(identifier: A18n.mainScreen.erxDetailedBlockRedeemAll)
            }
        }
    }
}

struct GroupedPrescriptionView_Previews: PreviewProvider {
    static let groupedPrescription = GroupedPrescription.Dummies.prescriptions
    static let scannedGroupedPrescription = GroupedPrescription.Dummies.scannedPrescriptions

    static var previews: some View {
        Group {
            GroupedPrescriptionView(
                groupedPrescription: groupedPrescription,
                store: PrescriptionListDomain.Dummies.store
            )
            .preferredColorScheme(.light)
            .previewLayout(.fixed(width: 500.0, height: 300.0))
            .padding()
            GroupedPrescriptionView(
                groupedPrescription: scannedGroupedPrescription,
                store: PrescriptionListDomain.Dummies.store
            )
            .preferredColorScheme(.light)
            .previewLayout(.fixed(width: 500.0, height: 300.0))
            .padding()
            GroupedPrescriptionView(
                groupedPrescription: groupedPrescription,
                store: PrescriptionListDomain.Dummies.store
            )
            .previewLayout(.sizeThatFits)
            .padding()
            GroupedPrescriptionView(
                groupedPrescription: groupedPrescription,
                store: PrescriptionListDomain.Dummies.store
            )
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .extraExtraExtraLarge)
            .previewLayout(.sizeThatFits)
            .padding()
            GroupedPrescriptionView(
                groupedPrescription: groupedPrescription,
                store: PrescriptionListDomain.Dummies.store
            )
            .preferredColorScheme(.light)
            .previewLayout(.fixed(width: 500.0, height: 300.0))
            .padding()
            GroupedPrescriptionView(
                groupedPrescription: groupedPrescription,
                store: PrescriptionListDomain.Dummies.store
            )
            .previewLayout(.sizeThatFits)
            .padding()
            GroupedPrescriptionView(
                groupedPrescription: groupedPrescription,
                store: PrescriptionListDomain.Dummies.store
            )
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .extraExtraExtraLarge)
            .previewLayout(.sizeThatFits)
            .padding()
        }
    }
}
