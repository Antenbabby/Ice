//
//  HotkeysSettingsPane.swift
//  Ice
//

import SwiftUI

struct HotkeysSettingsPane: View {
    @EnvironmentObject var appState: AppState

    private var loc: LocalizationManager { appState.localizationManager }

    private var hotkeySettingsManager: HotkeySettingsManager {
        appState.settingsManager.hotkeySettingsManager
    }

    var body: some View {
        IceForm {
            IceSection(loc.localized(.menuBarSections)) {
                hotkeyRecorder(forSection: .hidden)
                hotkeyRecorder(forSection: .alwaysHidden)
            }
            IceSection(loc.localized(.menuBarItems)) {
                hotkeyRecorder(forAction: .searchMenuBarItems)
            }
            IceSection(loc.localized(.other)) {
                hotkeyRecorder(forAction: .enableIceBar)
                hotkeyRecorder(forAction: .showSectionDividers)
                hotkeyRecorder(forAction: .toggleApplicationMenus)
            }
        }
    }

    @ViewBuilder
    private func hotkeyRecorder(forAction action: HotkeyAction) -> some View {
        if let hotkey = hotkeySettingsManager.hotkey(withAction: action) {
            HotkeyRecorder(hotkey: hotkey) {
                switch action {
                case .toggleHiddenSection:
                    Text(loc.localized(.toggleHiddenSection))
                case .toggleAlwaysHiddenSection:
                    Text(loc.localized(.toggleAlwaysHiddenSection))
                case .searchMenuBarItems:
                    Text(loc.localized(.searchMenuBarItems))
                case .enableIceBar:
                    Text(loc.localized(.enableIceBar))
                case .showSectionDividers:
                    Text(loc.localized(.toggleSectionDividers))
                case .toggleApplicationMenus:
                    Text(loc.localized(.toggleApplicationMenus))
                }
            }
        }
    }

    @ViewBuilder
    private func hotkeyRecorder(forSection name: MenuBarSection.Name) -> some View {
        if appState.menuBarManager.section(withName: name)?.isEnabled == true {
            if case .hidden = name {
                hotkeyRecorder(forAction: .toggleHiddenSection)
            } else if case .alwaysHidden = name {
                hotkeyRecorder(forAction: .toggleAlwaysHiddenSection)
            }
        }
    }
}
