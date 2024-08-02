//
//  Copyright (c) 2024 gematik GmbH
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
import ComposableCoreLocation
import CoreLocationUI
import eRpStyleKit
import MapKit
import SwiftUI

enum MKCoordinateRegionContainer: Equatable {
    /// the region is manually changed
    case manual(MKCoordinateRegion)
    /// the region is changed by the delegate
    case delegate(MKCoordinateRegion)

    var region: MKCoordinateRegion {
        get {
            switch self {
            case let .manual(region),
                 let .delegate(region):
                return region
            }
        }
        set {
            switch self {
            case .manual:
                self = .manual(newValue)
            case .delegate:
                self = .delegate(newValue)
            }
        }
    }
}

// swiftlint:disable identifier_name
extension MKCoordinateRegion {
    var mapRect: MKMapRect {
        let topLeft = CLLocationCoordinate2D(
            latitude: center.latitude + (span.latitudeDelta / 2),
            longitude: center.longitude - (span.longitudeDelta / 2)
        )
        let bottomRight = CLLocationCoordinate2D(
            latitude: center.latitude - (span.latitudeDelta / 2),
            longitude: center.longitude + (span.longitudeDelta / 2)
        )

        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)

        return MKMapRect(
            origin: MKMapPoint(x: min(a.x, b.x), y: min(a.y, b.y)),
            size: MKMapSize(width: abs(a.x - b.x), height: abs(a.y - b.y))
        )
    }
}

// swiftlint:enable identifier_name

struct MapViewWithClustering: UIViewRepresentable {
    static var isTestingEnvironment: Bool = {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }()

    @Binding var region: MKCoordinateRegionContainer
    var showUserLocation = true
    var annotations: [PlaceholderAnnotation] = []
    var disableUserInteraction = false
    var onAnnotationTapped: (PlaceholderAnnotation) -> Void
    var onClusterTapped: ([PlaceholderAnnotation]) -> Void

    class Coordinator: NSObject, MKMapViewDelegate {
        lazy var greyView: UIView = {
            let greyView = UIView()
            greyView.backgroundColor = .gray
            return greyView
        }()

        var parent: MapViewWithClustering

        init(_ parent: MapViewWithClustering) {
            self.parent = parent
        }

        /// Handling the update of the region binding
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated _: Bool) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.parent.region = .delegate(mapView.region)
            }
        }

        /// Handling the annotation on the map
        func mapView(_: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? PlaceholderAnnotation else { return nil }
            return NormalAnnotationView(
                annotation: annotation,
                reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
            )
        }

        /// Handling the onTapped Gesture to navigate to pharmacy details
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let cluster = view.annotation as? MKClusterAnnotation {
                mapView.deselectAnnotation(view.annotation, animated: false)
                let clusterArray = cluster.memberAnnotations.compactMap { $0 as? PlaceholderAnnotation }
                parent.onClusterTapped(clusterArray)
            } else {
                guard let annotation = view.annotation as? PlaceholderAnnotation else { return }
                mapView.deselectAnnotation(annotation, animated: false)
                parent.onAnnotationTapped(annotation)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        MapViewWithClustering.Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let mapView = MKMapView()
        guard !Self.isTestingEnvironment else {
            let greyView = context.coordinator.greyView
            return greyView
        }
        mapView.delegate = context.coordinator
        mapView.setRegion(region.region, animated: false)
        mapView.mapType = .standard
        mapView.showsCompass = false
        mapView.showsUserLocation = showUserLocation
        mapView.isUserInteractionEnabled = !disableUserInteraction
        mapView.addAnnotations(annotations)

        mapView.register(
            NormalAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        mapView.register(
            ClusterAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )

        return mapView
    }

    func updateUIView(_ view: UIView, context _: Context) {
        guard !Self.isTestingEnvironment, let mapView = view as? MKMapView else {
            return
        }
        switch region {
        case let .manual(region):
            mapView.setVisibleMapRect(
                region.mapRect,
                edgePadding: .init(top: 32, left: 32, bottom: 32, right: 32),
                animated: true
            )
        case let .delegate(region):
            // Dispatch to avoid endless loop while dismissing
            DispatchQueue.main.async {
                mapView.setRegion(region, animated: true)
            }
        }

        let exitingAnnotations = mapView.annotations.compactMap { $0 as? PlaceholderAnnotation }

        let newAnnotations = annotations.filter { annotation in
            !exitingAnnotations.contains { $0.pharmacy.id == annotation.pharmacy.id }
        }

        if !newAnnotations.isEmpty {
            let notNeeded = exitingAnnotations.filter { annotation in
                !annotations.contains { $0.pharmacy.id == annotation.pharmacy.id }
            }
            mapView.removeAnnotations(notNeeded)
            mapView.addAnnotations(newAnnotations)
        }
    }
}

class PlaceholderAnnotation: NSObject, MKAnnotation {
    let pharmacy: PharmacyLocationViewModel
    let coordinate: CLLocationCoordinate2D

    init(pharmacy: PharmacyLocationViewModel, coordinate: CLLocationCoordinate2D) {
        self.pharmacy = pharmacy
        self.coordinate = coordinate
        super.init()
    }
}

class ClusterAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
        image = UIImage(asset: Asset.Map.mapMarker)

        if let cluster = annotation as? MKClusterAnnotation {
            let totalCount = cluster.memberAnnotations.count

            image = drawNumber(text: String(totalCount))
            displayPriority = .defaultLow
        }
    }

    private func drawNumber(text: String) -> UIImage {
        let image = Asset.Map.emptyMarker.image
        let renderer = UIGraphicsImageRenderer(size: image.size)

        return renderer.image { _ in
            image.draw(at: .zero)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle,
            ]

            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(x: (image.size.width - textSize.width) / 2,
                                  y: (image.size.height - textSize.height) / 3,
                                  width: textSize.width,
                                  height: textSize.height)

            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}

class NormalAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "clustering"
        centerOffset = CGPoint(x: 0, y: -20)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultLow
        guard let pharmacyAnnotation = annotation as? PlaceholderAnnotation
        else { return image = UIImage(asset: Asset.Map.mapMarker) }
        if pharmacyAnnotation.pharmacy.hoursOfOperation.isEmpty {
            image = UIImage(asset: Asset.Map.mapMarker)
        } else {
            image = pharmacyAnnotation.pharmacy.todayOpeningState
                .isOpen ? UIImage(asset: Asset.Map.mapMarker) : UIImage(asset: Asset.Map.closedMarker)
        }
        let pharmacyName = pharmacyAnnotation.pharmacy.name ?? L10n.phaSearchMapAnnotation.text
        let pharmacyAddress = pharmacyAnnotation.pharmacy.address?.fullAddress ?? ""
        accessibilityLabel = pharmacyAddress.isEmpty ? pharmacyName : "\(pharmacyName), \(pharmacyAddress)"
        accessibilityIdentifier = pharmacyAnnotation.pharmacy.telematikID
    }
}
