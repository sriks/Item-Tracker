import SwiftUI

// MARK: - Theme environment key

private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: any AppTheme = MonochromeTheme(scheme: .dark)
}

extension EnvironmentValues {
    var appTheme: any AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

// MARK: - Constants environment key

private struct DesignConstantsKey: EnvironmentKey {
    static let defaultValue = DesignConstants()
}

extension EnvironmentValues {
    var constants: DesignConstants {
        get { self[DesignConstantsKey.self] }
        set { self[DesignConstantsKey.self] = newValue }
    }
}

// MARK: - View modifiers

extension View {
    /// Injects the given theme into the SwiftUI environment.
    func appTheme(_ theme: any AppTheme) -> some View {
        environment(\.appTheme, theme)
    }
}
