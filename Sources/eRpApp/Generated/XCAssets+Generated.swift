// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum CardReader {
    internal static let cardReadPosition1 = ImageAsset(name: "CardReadPosition1")
    internal static let cardReadPosition2 = ImageAsset(name: "CardReadPosition2")
    internal static let cardReadVideo = ImageAsset(name: "CardReadVideo")
    internal static let cardReading = ImageAsset(name: "CardReading")
  }
  internal enum CardWall {
    internal static let apotheker1 = ImageAsset(name: "Apotheker1")
    internal static let appIconPlaceholder = ImageAsset(name: "AppIconPlaceholder")
    internal static let arzt1 = ImageAsset(name: "Arzt1")
    internal static let cardwallCard = ImageAsset(name: "Cardwall_card")
    internal static let ohNo = ImageAsset(name: "OhNo")
    internal static let onScreenEgk = ImageAsset(name: "OnScreenEgk")
    internal static let previewAppIcon = ImageAsset(name: "PreviewAppIcon")
    internal static let scanningCard = ImageAsset(name: "Scanning_card")
    internal static let apothekerin2 = ImageAsset(name: "apothekerin2")
    internal static let homescreenBg = ImageAsset(name: "homescreen_bg")
    internal static let ios = ImageAsset(name: "ios")
    internal static let nfc = ImageAsset(name: "nfc")
    internal static let phoneExclamationMark = ImageAsset(name: "phoneExclamationMark")
    internal static let pinLetter = ImageAsset(name: "pinLetter")
  }
  internal enum Illustrations {
    internal static let arztRedCircle = ImageAsset(name: "Arzt_RedCircle")
    internal static let celebrationYellowCircle = ImageAsset(name: "Celebration_YellowCircle")
    internal static let girlRedCircle = ImageAsset(name: "Girl_RedCircle")
    internal static let girlRedCircleLarge = ImageAsset(name: "Girl_RedCircle_large")
    internal static let groupShot = ImageAsset(name: "GroupShot")
    internal static let infoLogo = ImageAsset(name: "InfoLogo")
    internal static let ladyDeveloperBlueCircle = ImageAsset(name: "LadyDeveloper_BlueCircle")
    internal static let womanBlueCircle = ImageAsset(name: "Woman_BlueCircle")
    internal static let boyCircle = ImageAsset(name: "boy_circle")
    internal static let egkBlau = ImageAsset(name: "egkBlau")
    internal static let mannkarteCircle = ImageAsset(name: "mannkarte_circle")
    internal static let mannkarteCircleBlue = ImageAsset(name: "mannkarte_circle_blue")
    internal static let pharmacistArmRedCirle = ImageAsset(name: "pharmacistArm_RedCirle")
    internal static let pharmacistf1 = ImageAsset(name: "pharmacistf1")
    internal static let pharmacistm1 = ImageAsset(name: "pharmacistm1")
    internal static let practitionerf1 = ImageAsset(name: "practitionerf1")
    internal static let practitionerm1 = ImageAsset(name: "practitionerm1")
    internal static let redWoman23 = ImageAsset(name: "redWoman2-3")
    internal static let womanRedCircle = ImageAsset(name: "woman_redCircle")
    internal static let womanYellowCircle = ImageAsset(name: "woman_yellowCircle")
  }
  internal enum Main {
    internal static let checkmarkCloudGreen = ImageAsset(name: "CheckmarkCloudGreen")
    internal static let cloudSlashGrey = ImageAsset(name: "CloudSlashGrey")
    internal static let exclamationmarkCloudRed = ImageAsset(name: "ExclamationmarkCloudRed")
  }
  internal enum Map {
    internal static let closedMarker = ImageAsset(name: "ClosedMarker")
    internal static let emptyMarker = ImageAsset(name: "EmptyMarker")
    internal static let mapMarker = ImageAsset(name: "MapMarker")
  }
  internal enum Onboarding {
    internal static let apotheker = ImageAsset(name: "Apotheker")
    internal static let appLogo = ImageAsset(name: "AppLogo")
    internal static let boyGrannyGrandpa = ImageAsset(name: "boyGrannyGrandpa")
    internal static let developerCircle = ImageAsset(name: "developerCircle")
    internal static let doctorCircle = ImageAsset(name: "doctorCircle")
    internal static let handMitKarteCircle = ImageAsset(name: "handMitKarteCircle")
    internal static let handsCircle = ImageAsset(name: "handsCircle")
    internal static let logoNeuFahne = ImageAsset(name: "logoNeuFahne")
    internal static let logoNeuGematik = ImageAsset(name: "logoNeuGematik")
    internal static let paragraphCircle = ImageAsset(name: "paragraphCircle")
    internal static let womanWithPhoneCircle = ImageAsset(name: "womanWithPhoneCircle")
  }
  internal enum OrderEGK {
    internal static let blueEGK = ImageAsset(name: "blueEGK")
    internal static let womanShrug = ImageAsset(name: "womanShrug")
  }
  internal enum Pharmacy {
    internal static let pharmacyPlaceholder = ImageAsset(name: "PharmacyPlaceholder")
    internal static let btnApoLarge = ImageAsset(name: "btn_apo_large")
    internal static let btnApoSmall = ImageAsset(name: "btn_apo_small")
    internal static let btnCarLarge = ImageAsset(name: "btn_car_large")
    internal static let btnCarSmall = ImageAsset(name: "btn_car_small")
    internal static let btnLkwLarge = ImageAsset(name: "btn_lkw_large")
    internal static let btnLkwSmall = ImageAsset(name: "btn_lkw_small")
    internal static let eRxReadinessBadge = ImageAsset(name: "eRxReadinessBadge")
  }
  internal enum Prescriptions {
    internal enum Details {
      internal static let apothekerin = ImageAsset(name: "apothekerin")
      internal static let lampIcon = ImageAsset(name: "lampIcon")
      internal static let refreshLamp = ImageAsset(name: "refreshLamp")
    }
    internal static let checkmarkDouble = ImageAsset(name: "checkmarkDouble")
    internal static let datamatrix = ImageAsset(name: "datamatrix")
    internal static let initialPlaceholder = ImageAsset(name: "initialPlaceholder")
  }
  internal enum Profile {
    internal static let baby = ImageAsset(name: "Baby")
    internal static let boyWithCard = ImageAsset(name: "BoyWithCard")
    internal static let developer = ImageAsset(name: "Developer")
    internal static let doctor = ImageAsset(name: "Doctor")
    internal static let doctor2 = ImageAsset(name: "Doctor2")
    internal static let manWithPhone = ImageAsset(name: "ManWithPhone")
    internal static let oldDoctor = ImageAsset(name: "OldDoctor")
    internal static let oldMan = ImageAsset(name: "OldMan")
    internal static let oldWoman = ImageAsset(name: "OldWoman")
    internal static let pharmacist = ImageAsset(name: "Pharmacist")
    internal static let pharmacist2 = ImageAsset(name: "Pharmacist2")
    internal static let wheelchair = ImageAsset(name: "Wheelchair")
    internal static let womanWithPhone = ImageAsset(name: "WomanWithPhone")
  }
  internal enum Redeem {
    internal static let pharmacistBlue = ImageAsset(name: "pharmacistBlue")
  }
  internal enum Settings {
    internal enum LegalNotice {
      internal static let gematikLogo = ImageAsset(name: "gematikLogo")
    }
  }
  internal enum TabIcon {
    internal static let appLogoTabItem = ImageAsset(name: "AppLogoTabItem")
    internal static let bag = ImageAsset(name: "bag")
    internal static let gearshape = ImageAsset(name: "gearshape")
    internal static let mapPinAndEllipse = ImageAsset(name: "mapPinAndEllipse")
  }
  internal static let findCan = ImageAsset(name: "find_can")
  internal enum LaunchAssets {
    internal static let g = ImageAsset(name: "g")
    internal static let logoGematik = ImageAsset(name: "logo_gematik")
    internal static let srgLeft = ImageAsset(name: "srg_left")
    internal static let srgSmallLeft = ImageAsset(name: "srg_small_left")
  }
  internal enum Registration {
    internal static let egk = ImageAsset(name: "egk")
  }
  internal enum Scanner {
    internal static let alert = ImageAsset(name: "alert")
    internal static let cameraFocusFrame = ImageAsset(name: "cameraFocusFrame")
    internal static let check = ImageAsset(name: "check")
    internal static let info = ImageAsset(name: "info")
  }
  internal enum Welcome {
    internal static let welcomeImage = ImageAsset(name: "welcomeImage")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
internal final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
