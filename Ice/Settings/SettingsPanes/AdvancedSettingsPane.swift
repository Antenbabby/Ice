//
//  AdvancedSettingsPane.swift
//  Ice
//

import SwiftUI

struct AdvancedSettingsPane: View {
    @EnvironmentObject var appState: AppState
    @State private var maxSliderLabelWidth: CGFloat = 0

    private var loc: LocalizationManager { appState.localizationManager }

    private var menuBarManager: MenuBarManager {
        appState.menuBarManager
    }

    private var manager: AdvancedSettingsManager {
        appState.settingsManager.advancedSettingsManager
    }

    private func formattedToSeconds(_ interval: TimeInterval) -> String {
        let formatted = interval.formatted()
        return if interval == 1 {
            formatted + " " + loc.localized(.second)
        } else {
            formatted + " " + loc.localized(.seconds)
        }
    }

    var body: some View {
        IceForm {
            IceSection {
                hideApplicationMenus
                showSectionDividers
                showAllSectionsOnUserDrag
                showContextMenuOnRightClick
            }
            IceSection {
                enableAlwaysHiddenSection
                canToggleAlwaysHiddenSection
            }
            IceSection {
                showOnHoverDelaySlider
                tempShowIntervalSlider
            }
            IceSection(loc.localized(.permissions)) {
                allPermissions
            }
        }
    }

    @ViewBuilder
    private var hideApplicationMenus: some View {
        Toggle(loc.localized(.hideApplicationMenus), isOn: manager.bindings.hideApplicationMenus)
            .annotation(LocalizedStringKey(loc.localized(.hideApplicationMenusDetail)))
    }

    @ViewBuilder
    private var showSectionDividers: some View {
        Toggle(loc.localized(.showSectionDividers), isOn: manager.bindings.showSectionDividers)
            .annotation {
                HStack(spacing: 2) {
                    Text(loc.localized(.showSectionDividersDetailPrefix))
                    if let nsImage = ControlItemImage.builtin(.chevronLarge).nsImage(for: appState) {
                        HStack(spacing: 0) {
                            Text("(")
                                .font(.body.monospaced().bold())
                            Image(nsImage: nsImage)
                                .padding(.horizontal, -2)
                            Text(")")
                                .font(.body.monospaced().bold())
                        }
                    }
                    Text(loc.localized(.showSectionDividersDetailMiddle))
                }
            }
    }

    @ViewBuilder
    private var enableAlwaysHiddenSection: some View {
        Toggle(loc.localized(.enableAlwaysHiddenSection), isOn: manager.bindings.enableAlwaysHiddenSection)
    }

    @ViewBuilder
    private var canToggleAlwaysHiddenSection: some View {
        if manager.enableAlwaysHiddenSection {
            Toggle(loc.localized(.canToggleAlwaysHiddenSection), isOn: manager.bindings.canToggleAlwaysHiddenSection)
                .annotation {
                    if appState.settingsManager.generalSettingsManager.showOnClick {
                        Text(loc.localized(.toggleAlwaysHiddenSectionDetailWithOption))
                    } else {
                        Text(loc.localized(.toggleAlwaysHiddenSectionDetail))
                    }
                }
        }
    }

    @ViewBuilder
    private var showOnHoverDelaySlider: some View {
        IceLabeledContent {
            IceSlider(
                LocalizedStringKey(formattedToSeconds(manager.showOnHoverDelay)),
                value: manager.bindings.showOnHoverDelay,
                in: 0...1,
                step: 0.1
            )
        } label: {
            Text(loc.localized(.showOnHoverDelay))
                .frame(minHeight: .compactSliderMinHeight)
                .frame(minWidth: maxSliderLabelWidth, alignment: .leading)
                .onFrameChange { frame in
                    maxSliderLabelWidth = max(maxSliderLabelWidth, frame.width)
                }
        }
        .annotation(LocalizedStringKey(loc.localized(.showOnHoverDelayDetail)))
    }

    @ViewBuilder
    private var tempShowIntervalSlider: some View {
        IceLabeledContent {
            IceSlider(
                LocalizedStringKey(formattedToSeconds(manager.tempShowInterval)),
                value: manager.bindings.tempShowInterval,
                in: 0...30,
                step: 1
            )
        } label: {
            Text(loc.localized(.tempShowInterval))
                .frame(minHeight: .compactSliderMinHeight)
                .frame(minWidth: maxSliderLabelWidth, alignment: .leading)
                .onFrameChange { frame in
                    maxSliderLabelWidth = max(maxSliderLabelWidth, frame.width)
                }
        }
        .annotation(LocalizedStringKey(loc.localized(.tempShowIntervalDetail)))
    }

    @ViewBuilder
    private var showAllSectionsOnUserDrag: some View {
        Toggle(loc.localized(.showAllSectionsOnUserDrag), isOn: manager.bindings.showAllSectionsOnUserDrag)
    }

    @ViewBuilder
    private var showContextMenuOnRightClick: some View {
        Toggle(loc.localized(.showContextMenuOnRightClick), isOn: manager.bindings.showContextMenuOnRightClick)
    }

    @ViewBuilder
    private var allPermissions: some View {
        ForEach(appState.permissionsManager.allPermissions) { permission in
            IceLabeledContent {
                if permission.hasPermission {
                    Label {
                        Text(loc.localized(.permissionGranted))
                    } icon: {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(.green)
                    }
                } else {
                    Button(loc.localized(.grantPermission)) {
                        permission.performRequest()
                    }
                }
            } label: {
                Text(permission.title)
            }
            .frame(height: 22)
        }
    }
}

#Preview {
    AdvancedSettingsPane()
        .fixedSize()
        .environmentObject(AppState())
}
