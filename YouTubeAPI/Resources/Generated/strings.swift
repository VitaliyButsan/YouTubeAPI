// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Localizable.strings
  ///   YouTubeAPI
  /// 
  ///   Created by VitaliyButsan on 10.05.2022.
  internal static let apiKey = L10n.tr("Localizable", "apiKey", fallback: "AIzaSyBxF4G3kTicXsQwmzspB1yVlMwfMSZDivk")
  /// https://www.googleapis.com/youtube/v3
  internal static let baseURL = L10n.tr("Localizable", "baseURL", fallback: "https://www.googleapis.com/youtube/v3")
  /// UCRV1wrztaWRxYIP6MCjv5gg
  internal static let channelId1 = L10n.tr("Localizable", "channelId1", fallback: "UCRV1wrztaWRxYIP6MCjv5gg")
  /// UCClZiNLIqCqMAiLDLETO6Zw
  internal static let channelId2 = L10n.tr("Localizable", "channelId2", fallback: "UCClZiNLIqCqMAiLDLETO6Zw")
  /// UCtX85DMU0spTUmlASGKNbIA
  internal static let channelId3 = L10n.tr("Localizable", "channelId3", fallback: "UCtX85DMU0spTUmlASGKNbIA")
  /// UCQZpfoYXcjgKwhTFZ3W22Kg
  internal static let channelId4 = L10n.tr("Localizable", "channelId4", fallback: "UCQZpfoYXcjgKwhTFZ3W22Kg")
  /// brandingSettings, statistics
  internal static let channelsRequestParts = L10n.tr("Localizable", "channelsRequestParts", fallback: "brandingSettings, statistics")
  /// PageControlCell
  internal static let pageControlCellId = L10n.tr("Localizable", "pageControlCellId", fallback: "PageControlCell")
  /// PlaylistCell
  internal static let playlistCellId = L10n.tr("Localizable", "playlistCellId", fallback: "PlaylistCell")
  /// PlaylistItemCell
  internal static let playlistItemCellId = L10n.tr("Localizable", "playlistItemCellId", fallback: "PlaylistItemCell")
  /// snippet
  internal static let playlistItemsRequestParts = L10n.tr("Localizable", "playlistItemsRequestParts", fallback: "snippet")
  /// snippet
  internal static let playlistsRequestParts = L10n.tr("Localizable", "playlistsRequestParts", fallback: "snippet")
  /// statistics
  internal static let videosRequestParts = L10n.tr("Localizable", "videosRequestParts", fallback: "statistics")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
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
