//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

@testable import eRpFeatures
import FHIRVZD
import Nimble
import Pharmacy
import Testing

struct PharmacyRemoteDataStoreApiFilterTests {
    @Test
    func nearbySearch_emptyFiltersProducesEmptyResult() {
        let result = PharmacyRemoteDataStore.apiFiltersForNearbySearch(filter: [])
        expect(result).to(beEmpty())
    }

    @Test
    func nearbySearch_shipmentProducesTextVersand() {
        let result = PharmacyRemoteDataStore.apiFiltersForNearbySearch(filter: [.shipment])
        expect(result) == [PharmacyRemoteDataStoreFilter(key: "text", value: "Versand")]
    }

    @Test
    func nearbySearch_deliveryProducesTextBotendienst() {
        let result = PharmacyRemoteDataStore.apiFiltersForNearbySearch(filter: [.delivery])
        expect(result) == [PharmacyRemoteDataStoreFilter(key: "text", value: "Botendienst")]
    }

    @Test
    func nearbySearch_combinedTextFilters() {
        let result = PharmacyRemoteDataStore.apiFiltersForNearbySearch(filter: [.shipment, .delivery])
        expect(result) == [PharmacyRemoteDataStoreFilter(key: "text", value: "Versand Botendienst")]
    }

    @Test
    func nearbySearch_readyIsIgnored() {
        let result = PharmacyRemoteDataStore.apiFiltersForNearbySearch(filter: [.ready])
        expect(result).to(beEmpty())
    }

    @Test
    func nearbySearch_singleCharacteristicProducesTextWithGermanKeyword() {
        let result = PharmacyRemoteDataStore.apiFiltersForNearbySearch(
            filter: [.characteristic(.publicTransport)]
        )
        expect(result) == [PharmacyRemoteDataStoreFilter(key: "text", value: "ÖPNV")]
    }

    @Test
    func nearbySearch_multipleCharacteristicsProducesCombinedText() {
        let result = PharmacyRemoteDataStore.apiFiltersForNearbySearch(
            filter: [.characteristic(.publicTransport), .characteristic(.barrierFree)]
        )
        expect(result) == [PharmacyRemoteDataStoreFilter(key: "text", value: "ÖPNV Barrierefrei")]
    }

    @Test
    func nearbySearch_deliveryWithCharacteristicsProducesCombinedText() {
        let result = PharmacyRemoteDataStore.apiFiltersForNearbySearch(
            filter: [.delivery, .characteristic(.parking), .characteristic(.pickupAutomat)]
        )
        expect(result) == [
            PharmacyRemoteDataStoreFilter(key: "text", value: "Botendienst Parkmöglichkeit Abholautomat"),
        ]
    }

    @Test
    func nearbySearch_allCharacteristicsMapToGermanKeywords() {
        let cases: [(PharmacyRepositoryFilter.Characteristic, String)] = [
            (.parking, "Parkmöglichkeit"),
            (.publicTransport, "ÖPNV"),
            (.barrierFree, "Barrierefrei"),
            (.pickupAutomat, "Abholautomat"),
        ]
        for (characteristic, expectedText) in cases {
            let result = PharmacyRemoteDataStore.apiFiltersForNearbySearch(
                filter: [.characteristic(characteristic)]
            )
            expect(result) == [PharmacyRemoteDataStoreFilter(key: "text", value: expectedText)]
        }
    }

    @Test
    func nearbySearch_singleSpecialtyProducesTextWithGermanKeyword() {
        let result = PharmacyRemoteDataStore.apiFiltersForNearbySearch(
            filter: [.specialty(.vaccination)]
        )
        expect(result) == [PharmacyRemoteDataStoreFilter(key: "text", value: "Impfung")]
    }

    @Test
    func nearbySearch_allSpecialtiesMapToGermanKeywords() {
        let cases: [(PharmacyRepositoryFilter.Specialty, String)] = [
            (.sterileCompounding, "Sterilherstellung"),
            (.hypertension, "Bluthochdruck"),
            (.inhalationTechnique, "Inhalationstechnik"),
            (.polymedication, "Polymedikation"),
            (.oralCancerTherapy, "Krebstherapie"),
            (.organTransplantation, "Organtransplantation"),
            (.vaccination, "Impfung"),
            (.bodyMeasurements, "Körperwerte"),
            (.allergyTest, "Allergietest"),
            (.travelMedicineConsultation, "Reisemedizin"),
        ]
        for (specialty, expectedText) in cases {
            let result = PharmacyRemoteDataStore.apiFiltersForNearbySearch(
                filter: [.specialty(specialty)]
            )
            expect(result) == [PharmacyRemoteDataStoreFilter(key: "text", value: expectedText)]
        }
    }

    @Test
    func nearbySearch_mixedFiltersAllCollectedIntoSingleTextParameter() {
        let result = PharmacyRemoteDataStore.apiFiltersForNearbySearch(
            filter: [.shipment, .characteristic(.barrierFree), .specialty(.vaccination)]
        )
        expect(result) == [
            PharmacyRemoteDataStoreFilter(key: "text", value: "Versand Barrierefrei Impfung"),
        ]
    }

    @Test
    func nearbySearch_multipleSpecialtiesProducesCombinedText() {
        let result = PharmacyRemoteDataStore.apiFiltersForNearbySearch(
            filter: [.specialty(.hypertension), .specialty(.allergyTest)]
        )
        expect(result) == [
            PharmacyRemoteDataStoreFilter(key: "text", value: "Bluthochdruck Allergietest"),
        ]
    }

    @Test
    func normalSearch_emptyFiltersProducesEmptyResult() {
        let result = PharmacyRemoteDataStore.apiFiltersForNormalSearch(filter: [])
        expect(result).to(beEmpty())
    }

    @Test
    func normalSearch_shipmentProducesSpecialty40() {
        let result = PharmacyRemoteDataStore.apiFiltersForNormalSearch(filter: [.shipment])
        expect(result) == [PharmacyRemoteDataStoreFilter(key: "specialty", value: "40")]
    }

    @Test
    func normalSearch_deliveryProducesSpecialty30() {
        let result = PharmacyRemoteDataStore.apiFiltersForNormalSearch(filter: [.delivery])
        expect(result) == [PharmacyRemoteDataStoreFilter(key: "specialty", value: "30")]
    }

    @Test
    func normalSearch_readyIsIgnored() {
        let result = PharmacyRemoteDataStore.apiFiltersForNormalSearch(filter: [.ready])
        expect(result).to(beEmpty())
    }

    @Test
    func normalSearch_singleCharacteristicProducesOneParameter() {
        let result = PharmacyRemoteDataStore.apiFiltersForNormalSearch(
            filter: [.characteristic(.barrierFree)]
        )
        expect(result) == [PharmacyRemoteDataStoreFilter(key: "characteristic", value: "barrierefrei")]
    }

    @Test
    func normalSearch_multipleCharacteristicsProduceSeparateParameters() {
        let result = PharmacyRemoteDataStore.apiFiltersForNormalSearch(
            filter: [
                .characteristic(.publicTransport),
                .characteristic(.parking),
                .characteristic(.barrierFree),
                .characteristic(.pickupAutomat),
            ]
        )
        expect(result) == [
            PharmacyRemoteDataStoreFilter(key: "characteristic", value: "oepnv"),
            PharmacyRemoteDataStoreFilter(key: "characteristic", value: "parkmoeglichkeit"),
            PharmacyRemoteDataStoreFilter(key: "characteristic", value: "barrierefrei"),
            PharmacyRemoteDataStoreFilter(key: "characteristic", value: "abholautomat"),
        ]
    }

    @Test
    func normalSearch_specialtyWithCharacteristics() {
        let result = PharmacyRemoteDataStore.apiFiltersForNormalSearch(
            filter: [.delivery, .shipment, .characteristic(.publicTransport), .characteristic(.pickupAutomat)]
        )
        expect(result) == [
            PharmacyRemoteDataStoreFilter(key: "specialty", value: "30"),
            PharmacyRemoteDataStoreFilter(key: "specialty", value: "40"),
            PharmacyRemoteDataStoreFilter(key: "characteristic", value: "oepnv"),
            PharmacyRemoteDataStoreFilter(key: "characteristic", value: "abholautomat"),
        ]
    }

    @Test
    func normalSearch_singleSpecialtyProducesSpecialtyParameter() {
        let result = PharmacyRemoteDataStore.apiFiltersForNormalSearch(
            filter: [.specialty(.vaccination)]
        )
        expect(result) == [PharmacyRemoteDataStoreFilter(key: "specialty", value: "impfung")]
    }

    @Test
    func normalSearch_mixedCharacteristicsAndSpecialties() {
        let result = PharmacyRemoteDataStore.apiFiltersForNormalSearch(
            filter: [.characteristic(.parking), .specialty(.hypertension), .delivery]
        )
        expect(result) == [
            PharmacyRemoteDataStoreFilter(key: "specialty", value: "30"),
            PharmacyRemoteDataStoreFilter(key: "characteristic", value: "parkmoeglichkeit"),
            PharmacyRemoteDataStoreFilter(key: "specialty", value: "60"),
        ]
    }
}
