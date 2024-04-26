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
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Colors {
    internal static let disabled = ColorAsset(name: "disabled")
    internal static let gifBackground = ColorAsset(name: "gifBackground")
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
    internal static let tabViewToolBarBackground = ColorAsset(name: "tabViewToolBarBackground")
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
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = Bundle.module
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }
}
#endif
