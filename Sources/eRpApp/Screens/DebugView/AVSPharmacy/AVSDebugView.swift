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

#if ENABLE_DEBUG_VIEW

import ComposableArchitecture
import eRpStyleKit
import SwiftUI

struct AVSDebugView: View {
    @AppStorage("debug_pharmacies") var debugPharmacies: [DebugPharmacy] = []

    var body: some View {
        List {
            ForEach($debugPharmacies) { pharmacy in
                NavigationLink(destination: DebugPharmacyView(pharmacy: pharmacy)) {
                    VStack(alignment: .leading) {
                        Text(pharmacy.wrappedValue.name)
                            .font(.headline)
                            .padding(.bottom, 2)
                        if let onPremise = pharmacy.onPremiseUrl.wrappedValue, !onPremise.isEmpty {
                            TextWithValue("OnPremise", value: onPremise)
                        }
                        if let shipment = pharmacy.shipmentUrl.wrappedValue, !shipment.isEmpty {
                            TextWithValue("Shipment", value: shipment)
                        }
                        if let delivery = pharmacy.deliveryUrl.wrappedValue, !delivery.isEmpty {
                            TextWithValue("Delivery", value: delivery)
                        }
                    }
                    .contextMenu {
                        Button(
                            action: {
                                UIPasteboard.general.string = pharmacy.wrappedValue.description
                            }, label: {
                                Label(L10n.dtlBtnCopyClipboard,
                                      systemImage: SFSymbolName.copy)
                            }
                        )
                    }
                }
            }.onDelete(perform: onDelete)
        }
        .navigationTitle("Debug Apotheken")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: {
                        withAnimation {
                            debugPharmacies.append(DebugPharmacy())
                        }
                    },
                    label: { Image(systemName: "plus") }
                )
            }
        }
    }

    func onDelete(at offsets: IndexSet) {
        debugPharmacies.remove(atOffsets: offsets)
    }

    private struct DebugPharmacyView: View {
        @Binding var pharmacy: DebugPharmacy

        var body: some View {
            VStack {
                List {
                    Section(header: Text("Name")) {
                        NavigationLink(destination: {
                            VStack {
                                TextField("Pharmacy Name", text: $pharmacy.name)
                                    .padding()
                                    .keyboardType(.default)
                                    .disableAutocorrection(true)
                                    .border(Color(.opaqueSeparator), width: 0.5, cornerRadius: 16)
                                Spacer()
                            }
                            .padding()
                        }, label: {
                            Text(pharmacy.name)
                        })
                    }

                    Section(header: Text("Urls")) {
                        NavigationLink(destination: {
                            EditUrlView(url: $pharmacy.onPremiseUrl)
                        }, label: {
                            TextWithValue("OnPremise URL", value: pharmacy.onPremiseUrl)
                        }).padding(.bottom, 4)

                        NavigationLink(destination: {
                            EditUrlView(url: $pharmacy.shipmentUrl)
                        }, label: {
                            TextWithValue("Shipment URL", value: pharmacy.shipmentUrl)
                        }).padding(.bottom, 4)

                        NavigationLink(destination: {
                            EditUrlView(url: $pharmacy.deliveryUrl)
                        }, label: {
                            TextWithValue("Delivery URL", value: pharmacy.deliveryUrl)
                        })
                    }

                    Section(header: Text("Zertifikate")) {
                        ForEach($pharmacy.certificates) { certificate in
                            NavigationLink(destination: {
                                EditCertificateView(name: certificate.name, value: certificate.derBase64)
                            }, label: {
                                TextWithValue(certificate.name.wrappedValue, value: certificate.derBase64.wrappedValue)
                            })
                        }
                        .onDelete(perform: onDelete)

                        Button("Zertifikat hinzufügen") {
                            withAnimation {
                                pharmacy.certificates
                                    .append(DebugPharmacy.Certificate(name: "Neues Zertifikat", derBase64: ""))
                            }
                        }
                    }
                }
            }
        }

        func onDelete(at offsets: IndexSet) {
            pharmacy.certificates.remove(atOffsets: offsets)
        }
    }

    private struct TextWithValue: View {
        let text: String
        let value: String

        init(_ text: String, value: String) {
            self.text = text
            self.value = value
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                if !value.isEmpty {
                    Text(value)
                        .font(.system(.footnote, design: .monospaced))
                        .lineLimit(3)
                }
            }
        }
    }
}

struct AVSDebugView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                AVSDebugView(
                    debugPharmacies: [
                        DebugPharmacy(
                            name: "Test",
                            onPremiseUrl: "https://dummy.url.com",
                            certificates: [
                                DebugPharmacy.Certificate(name: "Some name", derBase64: "asldfhaksdufhkasdjhf"),
                            ]
                        ),
                    ]
                )
            }

            AVSDebugView(
                debugPharmacies: [
                    DebugPharmacy(
                        name: "Test",
                        onPremiseUrl: "https://dummy.url.com",
                        certificates: [
                            DebugPharmacy.Certificate(name: "Some name", derBase64: "asldfhaksdufhkasdjhf"),
                        ]
                    ),
                ]
            )
            .preferredColorScheme(.dark)
        }
    }
}

#endif
