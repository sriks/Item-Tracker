import SwiftUI

// MARK: - Protocol

/// The shell theme — controls accent color, interactive surfaces, and CTA elements.
/// All color properties are pre-resolved for the current color scheme so views need only
/// one environment lookup: `@Environment(\.appTheme) private var colors`.
protocol AppTheme {
    // Semantic surface / text
    var primaryText: Color { get }
    var secondaryText: Color { get }
    var tertiaryText: Color { get }
    var cardBackground: Color { get }
    var inputBackground: Color { get }
    var hairline: Color { get }

    // Shell / accent
    var accent: Color { get }
    var accentMuted: Color { get }
    var accentBorder: Color { get }
    var searchBarBackground: Color { get }
    var searchBarBorder: Color { get }
    var tabBarBackground: Color { get }
    var activeTabForeground: Color { get }
    var micButtonBackground: Color { get }
    var answerPillBackground: Color { get }
    var answerPillForeground: Color { get }
    var ctaBackground: Color { get }
}

// MARK: - Monochrome (default)

/// Pure black/white — no accent. Room colours are the only colour in the UI, making them more meaningful.
struct MonochromeTheme: AppTheme {
    let scheme: ColorScheme
    private var isDark: Bool { scheme == .dark }

    var primaryText: Color     { isDark ? .white.opacity(0.92) : .black.opacity(0.88) }
    var secondaryText: Color   { isDark ? .white.opacity(0.36) : .black.opacity(0.38) }
    var tertiaryText: Color    { isDark ? .white.opacity(0.30) : .black.opacity(0.30) }
    var cardBackground: Color  { isDark ? .white.opacity(0.06) : .black.opacity(0.04) }
    var inputBackground: Color { isDark ? .white.opacity(0.09) : .black.opacity(0.06) }
    var hairline: Color        { isDark ? .white.opacity(0.09) : .black.opacity(0.08) }

    var accent: Color             { isDark ? .white : .black }
    var accentMuted: Color        { isDark ? .white.opacity(0.15) : .black.opacity(0.15) }
    var accentBorder: Color       { isDark ? .white.opacity(0.35) : .black.opacity(0.35) }
    var searchBarBackground: Color { isDark ? .white.opacity(0.09) : .black.opacity(0.06) }
    var searchBarBorder: Color    { isDark ? .white.opacity(0.18) : .black.opacity(0.14) }
    var tabBarBackground: Color   { isDark ? Color(white: 0.08).opacity(0.85) : Color(white: 0.92).opacity(0.88) }
    var activeTabForeground: Color { isDark ? .white.opacity(0.90) : .black.opacity(0.90) }
    var micButtonBackground: Color { isDark ? .white.opacity(0.10) : .black.opacity(0.08) }
    var answerPillBackground: Color { isDark ? .white.opacity(0.12) : .black.opacity(0.08) }
    var answerPillForeground: Color { isDark ? .white.opacity(0.95) : .black.opacity(0.90) }
    var ctaBackground: Color      { isDark ? .white.opacity(0.90) : .black.opacity(0.88) }
}

// MARK: - Accent themes

/// A parameterised accent theme. All five shell accent variants share the same colour logic;
/// they differ only in the accent colour value. Use the static factory methods for named themes.
struct AccentTheme: AppTheme {
    let scheme: ColorScheme
    let accentColor: Color

    private var isDark: Bool { scheme == .dark }
    private var mono: MonochromeTheme { MonochromeTheme(scheme: scheme) }

    // Semantic colours delegate to monochrome — accent themes only tint interactive elements.
    var primaryText: Color     { mono.primaryText }
    var secondaryText: Color   { mono.secondaryText }
    var tertiaryText: Color    { mono.tertiaryText }
    var cardBackground: Color  { mono.cardBackground }
    var inputBackground: Color { mono.inputBackground }
    var hairline: Color        { mono.hairline }

    var accent: Color             { accentColor }
    var accentMuted: Color        { accentColor.opacity(0.15) }
    var accentBorder: Color       { accentColor.opacity(0.35) }
    var searchBarBackground: Color { mono.searchBarBackground }
    var searchBarBorder: Color    { accentColor.opacity(0.40) }
    var tabBarBackground: Color   { mono.tabBarBackground }
    var activeTabForeground: Color { accentColor }
    var micButtonBackground: Color { accentColor.opacity(0.20) }
    var answerPillBackground: Color { accentColor.opacity(0.18) }
    var answerPillForeground: Color { mono.answerPillForeground }
    var ctaBackground: Color      { accentColor }
}

// MARK: Accent theme factories

extension AccentTheme {
    static func teal(scheme: ColorScheme) -> AccentTheme {
        AccentTheme(scheme: scheme, accentColor: Color(hex: "#1D9E75"))
    }

    static func coral(scheme: ColorScheme) -> AccentTheme {
        AccentTheme(scheme: scheme, accentColor: Color(hex: "#D85A30"))
    }

    static func indigo(scheme: ColorScheme) -> AccentTheme {
        AccentTheme(scheme: scheme, accentColor: Color(hex: "#7F77DD"))
    }

    static func amber(scheme: ColorScheme) -> AccentTheme {
        AccentTheme(scheme: scheme, accentColor: Color(hex: "#BA7517"))
    }

    static func arcticBlue(scheme: ColorScheme) -> AccentTheme {
        AccentTheme(scheme: scheme, accentColor: Color(hex: "#185FA5"))
    }
}
