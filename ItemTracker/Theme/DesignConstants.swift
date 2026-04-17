import CoreGraphics

/// All fixed design numbers for the app — shape and layout constants in one place.
enum DesignConstants {

    // MARK: - Shape

    static let cornerRadiusCard: CGFloat = 16
    static let cornerRadiusInput: CGFloat = 22
    static let cornerRadiusChip: CGFloat = 14
    static let cornerRadiusTag: CGFloat = 8
    static let cornerRadiusRoom: CGFloat = 12
    static let cornerRadiusTabBar: CGFloat = 32
    static let borderWidth: CGFloat = 0.5

    // MARK: - Layout

    /// Horizontal padding from screen edges.
    static let horizontalPadding: CGFloat = 26
    /// Vertical spacing between major sections.
    static let sectionSpacing: CGFloat = 28
    /// Vertical gap between items within a section.
    static let itemGap: CGFloat = 8
    /// Space between the floating tab bar and the home indicator.
    static let tabBarBottomPadding: CGFloat = 8
    /// Space between the search bar and the top of the tab bar.
    static let searchBarBottomPadding: CGFloat = 16
}
