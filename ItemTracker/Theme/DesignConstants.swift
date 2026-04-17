import CoreGraphics

/// All fixed design numbers for the app — shape and layout constants in one place.
/// Injected as `@Environment(\.constants)` so views never reference raw numbers directly.
struct DesignConstants {
    // MARK: - Shape

    let cornerRadiusCard: CGFloat = 16
    let cornerRadiusInput: CGFloat = 22
    let cornerRadiusChip: CGFloat = 14
    let cornerRadiusTag: CGFloat = 8
    let cornerRadiusRoom: CGFloat = 12
    let cornerRadiusTabBar: CGFloat = 32
    let borderWidth: CGFloat = 0.5

    // MARK: - Layout

    /// Horizontal padding from screen edges.
    let horizontalPadding: CGFloat = 26
    /// Vertical spacing between major sections.
    let sectionSpacing: CGFloat = 28
    /// Vertical gap between items within a section.
    let itemGap: CGFloat = 8
    /// Space between the floating tab bar and the home indicator.
    let tabBarBottomPadding: CGFloat = 8
    /// Space between the search bar and the top of the tab bar.
    let searchBarBottomPadding: CGFloat = 16
}
