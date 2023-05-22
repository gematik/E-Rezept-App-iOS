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

#if ENABLE_DEBUG_VIEW

import ComposableArchitecture
import eRpStyleKit
import SwiftUI

struct AVSDebugView: View {
    @AppStorage("debug_pharmacies") var debugPharmacies: [DebugPharmacy] = []

    @State
    var importViaQRCode = false

    var body: some View {
        List {
            ForEach($debugPharmacies) { $pharmacy in
                NavigationLink(destination: DebugPharmacyView(pharmacy: $pharmacy)) {
                    VStack(alignment: .leading) {
                        Text(pharmacy.name)
                            .font(.headline)
                            .padding(.bottom, 2)
                        let onPremise = pharmacy.onPremiseUrl.url
                        if !onPremise.isEmpty {
                            TextWithValue("OnPremise", value: onPremise)
                        }
                        let shipment = pharmacy.shipmentUrl.url
                        if !shipment.isEmpty {
                            TextWithValue("Shipment", value: shipment)
                        }
                        let delivery = pharmacy.deliveryUrl.url
                        if !delivery.isEmpty {
                            TextWithValue("Delivery", value: delivery)
                        }
                    }
                    .contextMenu {
                        Button(
                            action: {
                                UIPasteboard.general.string = pharmacy.description
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: {
                        withAnimation {
                            importViaQRCode = true
                        }
                    },
                    label: { Image(systemName: SFSymbolName.qrCode) }
                )
            }
        }
        .sheet(isPresented: $importViaQRCode) {
            DebugQRCodeImporter<DebugPharmacy>(scan: $importViaQRCode) { newPharmacy in
                // Rewrite id to enable multiple scans of the same pharmacy. If two pharmacies with the same ID are
                // present, SwiftUI will have a hard time figuring out, what pharmacy is edited.
                var newPharmacy = newPharmacy
                newPharmacy.id = UUID()
                debugPharmacies.append(newPharmacy)
                importViaQRCode = false
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
                            EditUrlView(endpoint: $pharmacy.onPremiseUrl)
                        }, label: {
                            TextWithValue("OnPremise URL", value: pharmacy.onPremiseUrl.url)
                        }).padding(.bottom, 4)

                        NavigationLink(destination: {
                            EditUrlView(endpoint: $pharmacy.shipmentUrl)
                        }, label: {
                            TextWithValue("Shipment URL", value: pharmacy.shipmentUrl.url)
                        }).padding(.bottom, 4)

                        NavigationLink(destination: {
                            EditUrlView(endpoint: $pharmacy.deliveryUrl)
                        }, label: {
                            TextWithValue("Delivery URL", value: pharmacy.deliveryUrl.url)
                        })
                    }

                    Section(header: Text("Zertifikate")) {
                        ForEach($pharmacy.certificates) { $certificate in
                            NavigationLink(destination: {
                                EditCertificateView(name: $certificate.name, value: $certificate.derBase64)
                            }, label: {
                                TextWithValue(certificate.name, value: certificate.derBase64)
                            })
                        }
                        .onDelete(perform: onDelete)

                        Button("Zertifikat hinzufügen") {
                            withAnimation {
                                $pharmacy.certificates.wrappedValue
                                    .append(DebugPharmacy.Certificate(name: "Neues Zertifikat", derBase64: ""))
                            }
                        }
                    }

                    Section(
                        header: Text("Export this Pharamcy"),
                        footer: Text("""
                        Use \(Image(systemName: SFSymbolName.qrCode)) on previous screen for import.

                        **Note: Certificates are stripped, to reduce QR-Code size.**
                        """)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    ) {
                        NavigationLink(destination: {
                            DebugQRCodeExporter(content: { () -> DebugPharmacy in
                                var pharmacy = pharmacy
                                pharmacy.certificates = []
                                return pharmacy
                            }())
                        }, label: {
                            Text("Export")
                        })
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
                            onPremiseUrl: .init(url: "https://dummy.url.com"),
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
                        onPremiseUrl: .init(url: "https://dummy.url.com"),
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
