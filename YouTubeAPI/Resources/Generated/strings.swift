// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// AIzaSyBxF4G3kTicXsQwmzspB1yVlMwfMSZDivk
  internal static let apiKey = L10n.tr("Localizable", "apiKey")
  /// https://www.googleapis.com/youtube/v3
  internal static let baseURL = L10n.tr("Localizable", "baseURL")
  /// UC18bHNKD21woNT7G0F4PN7Q
  internal static let channelId1 = L10n.tr("Localizable", "channelId1")
  /// UCqhmK0ACxRHCXcoXXaId15Q
  internal static let channelId2 = L10n.tr("Localizable", "channelId2")
  /// UCvmxzBDt6zpM1BhZaGeiV0Q
  internal static let channelId3 = L10n.tr("Localizable", "channelId3")
  /// UC9_DJQL7CPkR9PhjfRZAnlw
  internal static let channelId4 = L10n.tr("Localizable", "channelId4")
  /// brandingSettings, statistics
  internal static let channelsRequestParts = L10n.tr("Localizable", "channelsRequestParts")
  /// snippet
  internal static let playlistItemsRequestParts = L10n.tr("Localizable", "playlistItemsRequestParts")
  /// snippet
  internal static let playlistsRequestParts = L10n.tr("Localizable", "playlistsRequestParts")
  /// statistics
  internal static let videosRequestParts = L10n.tr("Localizable", "videosRequestParts")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
