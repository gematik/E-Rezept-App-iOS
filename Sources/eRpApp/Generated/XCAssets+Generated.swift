// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import SwiftUI
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum CardReader {
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
    internal static let apothekerin2 = ImageAsset(name: "apothekerin2")
    internal static let homescreenBg = ImageAsset(name: "homescreen_bg")
    internal static let ios = ImageAsset(name: "ios")
    internal static let nfc = ImageAsset(name: "nfc")
    internal static let phoneExclamationMark = ImageAsset(name: "phoneExclamationMark")
    internal static let pinLetter = ImageAsset(name: "pinLetter")
  }
  internal enum Colors {
    internal static let disabled = ColorAsset(name: "disabled")
    internal static let primary100 = ColorAsset(name: "primary100")
    internal static let primary200 = ColorAsset(name: "primary200")
    internal static let primary300 = ColorAsset(name: "primary300")
    internal static let primary400 = ColorAsset(name: "primary400")
    internal static let primary500 = ColorAsset(name: "primary500")
    internal static let primary600 = ColorAsset(name: "primary600")
    internal static let primary700 = ColorAsset(name: "primary700")
    internal static let primary800 = ColorAsset(name: "primary800")
    internal static let primary900 = ColorAsset(name: "primary900")
    internal static let red100 = ColorAsset(name: "red100")
    internal static let red200 = ColorAsset(name: "red200")
    internal static let red300 = ColorAsset(name: "red300")
    internal static let red400 = ColorAsset(name: "red400")
    internal static let red500 = ColorAsset(name: "red500")
    internal static let red600 = ColorAsset(name: "red600")
    internal static let red700 = ColorAsset(name: "red700")
    internal static let red800 = ColorAsset(name: "red800")
    internal static let red900 = ColorAsset(name: "red900")
    internal static let secondary100 = ColorAsset(name: "secondary100")
    internal static let secondary200 = ColorAsset(name: "secondary200")
    internal static let secondary300 = ColorAsset(name: "secondary300")
    internal static let secondary400 = ColorAsset(name: "secondary400")
    internal static let secondary500 = ColorAsset(name: "secondary500")
    internal static let secondary600 = ColorAsset(name: "secondary600")
    internal static let secondary700 = ColorAsset(name: "secondary700")
    internal static let secondary800 = ColorAsset(name: "secondary800")
    internal static let secondary900 = ColorAsset(name: "secondary900")
    internal static let yellow100 = ColorAsset(name: "yellow100")
    internal static let yellow200 = ColorAsset(name: "yellow200")
    internal static let yellow300 = ColorAsset(name: "yellow300")
    internal static let yellow400 = ColorAsset(name: "yellow400")
    internal static let yellow500 = ColorAsset(name: "yellow500")
    internal static let yellow600 = ColorAsset(name: "yellow600")
    internal static let yellow700 = ColorAsset(name: "yellow700")
    internal static let yellow800 = ColorAsset(name: "yellow800")
    internal static let yellow900 = ColorAsset(name: "yellow900")
  }
  internal enum Illustrations {
    internal static let arztRedCircle = ImageAsset(name: "Arzt_RedCircle")
    internal static let celebrationYellowCircle = ImageAsset(name: "Celebration_YellowCircle")
    internal static let girlRedCircle = ImageAsset(name: "Girl_RedCircle")
    internal static let girlRedCircleLarge = ImageAsset(name: "Girl_RedCircle_large")
    internal static let groupShot = ImageAsset(name: "GroupShot")
    internal static let info = ImageAsset(name: "Info")
    internal static let ladyDeveloperBlueCircle = ImageAsset(name: "LadyDeveloper_BlueCircle")
    internal static let womanBlueCircle = ImageAsset(name: "Woman_BlueCircle")
    internal static let boyCicrle = ImageAsset(name: "boy_Cicrle")
    internal static let egkBlau = ImageAsset(name: "egkBlau")
    internal static let mannkarteCircle = ImageAsset(name: "mannkarte_circle")
    internal static let pharmacistArmRedCirle = ImageAsset(name: "pharmacistArm_RedCirle")
    internal static let pharmacistf1 = ImageAsset(name: "pharmacistf1")
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
  internal enum Onboarding {
    internal static let apotheker = ImageAsset(name: "Apotheker")
    internal static let appLogo = ImageAsset(name: "AppLogo")
    internal static let boyGrannyGrandpa = ImageAsset(name: "boyGrannyGrandpa")
    internal static let developer = ImageAsset(name: "developer")
    internal static let doctor = ImageAsset(name: "doctor")
    internal static let handMitKarte = ImageAsset(name: "handMitKarte")
    internal static let logoNeuFahne = ImageAsset(name: "logoNeuFahne")
    internal static let logoNeuGematik = ImageAsset(name: "logoNeuGematik")
    internal static let paragraph = ImageAsset(name: "paragraph")
    internal static let womanWithPhone = ImageAsset(name: "womanWithPhone")
  }
  internal enum Pharmacy {
    internal static let pharmacyPlaceholder = ImageAsset(name: "PharmacyPlaceholder")
    internal static let eRxReadinessBadge = ImageAsset(name: "eRxReadinessBadge")
  }
  internal enum Prescriptions {
    internal enum Details {
      internal static let apothekerin = ImageAsset(name: "apothekerin")
    }
    internal static let checkmarkDouble = ImageAsset(name: "checkmarkDouble")
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

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = SwiftUI.Color
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(asset.name, bundle: bundle)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

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
}

internal extension ImageAsset.Image {
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

