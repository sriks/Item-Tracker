import SwiftUI

/// Room colour tokens used for spatial colour coding.
/// Values are vivid enough to read on both dark and light backgrounds — they do not flip between modes.
enum ColorToken: String, Codable, CaseIterable {
    case amber
    case blue
    case purple
    case green
    case coral
    case teal
    case pink
    case red

    var color: Color {
        switch self {
        case .amber: Color(hex: "#EF9F27")
        case .blue: Color(hex: "#378ADD")
        case .purple: Color(hex: "#7F77DD")
        case .green: Color(hex: "#639922")
        case .coral: Color(hex: "#D85A30")
        case .teal: Color(hex: "#1D9E75")
        case .pink: Color(hex: "#D4537E")
        case .red: Color(hex: "#E24B4A")
        }
    }
}
