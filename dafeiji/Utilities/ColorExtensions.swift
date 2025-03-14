import SwiftUI

extension Color {
    static var systemBackground: Color {
        #if os(iOS)
        return Color(uiColor: .systemBackground)
        #else
        return Color(nsColor: .windowBackgroundColor)
        #endif
    }
    
    static var systemGray6: Color {
        #if os(iOS)
        return Color(uiColor: .systemGray6)
        #else
        return Color(nsColor: .controlBackgroundColor)
        #endif
    }
} 