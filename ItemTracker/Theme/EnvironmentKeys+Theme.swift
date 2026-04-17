import SwiftUI

extension EnvironmentValues {
    @Entry var appTheme: any AppTheme = MonochromeTheme(scheme: .dark)
}

extension EnvironmentValues {
    @Entry var constants = DesignConstants()
}

// MARK: - View modifiers

extension View {
    /// Injects the given theme into the SwiftUI environment.
    func appTheme(_ theme: any AppTheme) -> some View {
        environment(\.appTheme, theme)
    }
}
