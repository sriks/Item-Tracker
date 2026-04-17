import SwiftUI

// MARK: - Environment key

private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: any AppTheme = MonochromeTheme(scheme: .dark)
}

extension EnvironmentValues {
    var appTheme: any AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

// MARK: - View modifier

extension View {
    /// Injects the given theme into the SwiftUI environment.
    func appTheme(_ theme: any AppTheme) -> some View {
        environment(\.appTheme, theme)
    }
}
