//
//  SettingsNavigationIdentifier.swift
//  Ice
//

/// An identifier used for navigation in the settings interface.
enum SettingsNavigationIdentifier: String, NavigationIdentifier {
    case general = "General"
    case menuBarLayout = "Menu Bar Layout"
    case menuBarAppearance = "Menu Bar Appearance"
    case hotkeys = "Hotkeys"
    case advanced = "Advanced"
    case about = "About"

    var localizationKey: LocalizationKey {
        switch self {
        case .general: .general
        case .menuBarLayout: .menuBarLayout
        case .menuBarAppearance: .menuBarAppearance
        case .hotkeys: .hotkeys
        case .advanced: .advanced
        case .about: .about
        }
    }
}
