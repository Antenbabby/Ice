//
//  GeneralSettingsPane.swift
//  Ice
//

import LaunchAtLogin
import SwiftUI

struct GeneralSettingsPane: View {
    @EnvironmentObject var appState: AppState
    @State private var isImportingCustomIceIcon = false
    @State private var isPresentingError = false
    @State private var presentedError: LocalizedErrorWrapper?
    @State private var isApplyingOffset = false
    @State private var tempItemSpacingOffset: CGFloat = 0 // Temporary state for the slider

    private var loc: LocalizationManager { appState.localizationManager }

    private var manager: GeneralSettingsManager {
        appState.settingsManager.generalSettingsManager
    }

    private var itemSpacingOffset: String {
        localizedOffsetString(for: manager.itemSpacingOffset)
    }

    private func localizedOffsetString(for offset: CGFloat) -> String {
        switch offset {
        case -16:
            return loc.localized(.none_)
        case 0:
            return loc.localized(.default_)
        case 16:
            return loc.localized(.max)
        default:
            return offset.formatted()
        }
    }

    private var rehideIntervalLabel: String {
        let formatted = manager.rehideInterval.formatted()
        if manager.rehideInterval == 1 {
            return formatted + " " + loc.localized(.second)
        } else {
            return formatted + " " + loc.localized(.seconds)
        }
    }

    private var hasSpacingSliderValueChanged: Bool {
        tempItemSpacingOffset != manager.itemSpacingOffset
    }

    private var isActualOffsetDifferentFromDefault: Bool {
        manager.itemSpacingOffset != 0
    }

    var body: some View {
        IceForm {
            IceSection {
                languagePicker
            }
            IceSection {
                launchAtLogin
            }
            IceSection {
                iceIconOptions
            }
            IceSection {
                iceBarOptions
            }
            IceSection {
                showOnClick
                showOnHover
                showOnScroll
            }
            IceSection {
                autoRehideOptions
            }
            IceSection {
                spacingOptions
            }
        }
        .alert(isPresented: $isPresentingError, error: presentedError) {
            Button(loc.localized(.ok)) {
                presentedError = nil
                isPresentingError = false
            }
        }
    }

    @ViewBuilder
    private var languagePicker: some View {
        IcePicker(loc.localized(.language), selection: appState.localizationManager.bindings.language) {
            ForEach(AppLanguage.allCases) { language in
                Text(loc.localizedKey(language.localizationKey)).tag(language)
            }
        }
        .annotation(loc.localized(.languageAnnotation))
    }

    @ViewBuilder
    private var launchAtLogin: some View {
        LaunchAtLogin.Toggle()
    }

    @ViewBuilder
    private func menuItem(for imageSet: ControlItemImageSet) -> some View {
        Label {
            Text(imageSet.name.rawValue)
        } icon: {
            if let nsImage = imageSet.hidden.nsImage(for: appState) {
                switch imageSet.name {
                case .custom:
                    Image(size: CGSize(width: 18, height: 18)) { context in
                        context.draw(
                            Image(nsImage: nsImage),
                            in: context.clipBoundingRect
                        )
                    }
                default:
                    Image(nsImage: nsImage)
                }
            }
        }
    }

    @ViewBuilder
    private var iceIconOptions: some View {
        Toggle(loc.localized(.showIceIcon), isOn: manager.bindings.showIceIcon)
            .annotation {
                if !manager.showIceIcon {
                    Text(loc.localized(.iceIconSettings))
                }
            }
        if manager.showIceIcon {
            IceMenu(loc.localized(.iceIcon)) {
                Picker(loc.localized(.iceIcon), selection: manager.bindings.iceIcon) {
                    ForEach(ControlItemImageSet.userSelectableIceIcons) { imageSet in
                        Button {
                            manager.iceIcon = imageSet
                        } label: {
                            menuItem(for: imageSet)
                        }
                        .tag(imageSet)
                    }
                    if let lastCustomIceIcon = manager.lastCustomIceIcon {
                        Button {
                            manager.iceIcon = lastCustomIceIcon
                        } label: {
                            menuItem(for: lastCustomIceIcon)
                        }
                        .tag(lastCustomIceIcon)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()

                Divider()

                Button(loc.localized(.chooseImage)) {
                    isImportingCustomIceIcon = true
                }
            } title: {
                menuItem(for: manager.iceIcon)
            }
            .annotation(loc.localized(.chooseCustomIcon))
            .fileImporter(
                isPresented: $isImportingCustomIceIcon,
                allowedContentTypes: [.image]
            ) { result in
                do {
                    let url = try result.get()
                    if url.startAccessingSecurityScopedResource() {
                        defer { url.stopAccessingSecurityScopedResource() }
                        let data = try Data(contentsOf: url)
                        manager.iceIcon = ControlItemImageSet(name: .custom, image: .data(data))
                    }
                } catch {
                    presentedError = LocalizedErrorWrapper(error)
                    isPresentingError = true
                }
            }

            if case .custom = manager.iceIcon.name {
                Toggle(loc.localized(.applySystemTheme), isOn: manager.bindings.customIceIconIsTemplate)
                    .annotation(loc.localized(.applySystemThemeDetail))
            }
        }
    }

    @ViewBuilder
    private var iceBarOptions: some View {
        useIceBar
        if manager.useIceBar {
            iceBarLocationPicker
        }
    }

    @ViewBuilder
    private var useIceBar: some View {
        Toggle(loc.localized(.useIceBar), isOn: manager.bindings.useIceBar)
            .annotation(loc.localized(.useIceBarDetail))
    }

    @ViewBuilder
    private var iceBarLocationPicker: some View {
        IcePicker(loc.localized(.location), selection: manager.bindings.iceBarLocation) {
            ForEach(IceBarLocation.allCases) { location in
                Text(loc.localizedKey(location.localizationKey)).tag(location)
            }
        }
        .annotation {
            switch manager.iceBarLocation {
            case .dynamic:
                Text(loc.localized(.locationDynamic))
            case .mousePointer:
                Text(loc.localized(.locationMousePointer))
            case .iceIcon:
                Text(loc.localized(.locationIceIcon))
            }
        }
    }

    @ViewBuilder
    private var showOnClick: some View {
        Toggle(loc.localized(.showOnClick), isOn: manager.bindings.showOnClick)
            .annotation(loc.localized(.showOnClickDetail))
    }

    @ViewBuilder
    private var showOnHover: some View {
        Toggle(loc.localized(.showOnHover), isOn: manager.bindings.showOnHover)
            .annotation(loc.localized(.showOnHoverDetail))
    }

    @ViewBuilder
    private var showOnScroll: some View {
        Toggle(loc.localized(.showOnScroll), isOn: manager.bindings.showOnScroll)
            .annotation(loc.localized(.showOnScrollDetail))
    }

    @ViewBuilder
    private var spacingOptions: some View {
        IceLabeledContent {
            IceSlider(
                LocalizedStringKey(localizedOffsetString(for: tempItemSpacingOffset)),
                value: $tempItemSpacingOffset,
                in: -16...16,
                step: 2
            )
            .disabled(isApplyingOffset)
        } label: {
            IceLabeledContent {
                Button(loc.localized(.apply)) {
                    applyOffset()
                }
                .help(loc.localized(.applySpacing))
                .disabled(isApplyingOffset || !hasSpacingSliderValueChanged)

                if isApplyingOffset {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.5)
                        .frame(width: 15, height: 15)
                } else {
                    Button {
                        resetOffsetToDefault()
                    } label: {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                    }
                    .buttonStyle(.borderless)
                    .help(loc.localized(.resetToDefault))
                    .disabled(isApplyingOffset || !isActualOffsetDifferentFromDefault)
                }
            } label: {
                HStack {
                    Text(loc.localized(.menuBarItemSpacing))
                    BetaBadge()
                }
            }
        }
        .annotation(loc.localized(.spacingRelaunchNote), spacing: 2)
        .annotation(spacing: 10, font: .callout.bold()) {
            IceGroupBox {
                Label {
                    Text(loc.localized(.spacingLogoutNote))
                } icon: {
                    Image(systemName: "exclamationmark.circle")
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            tempItemSpacingOffset = manager.itemSpacingOffset
        }
    }

    @ViewBuilder
    private var rehideStrategyPicker: some View {
        IcePicker(loc.localized(.strategy), selection: manager.bindings.rehideStrategy) {
            ForEach(RehideStrategy.allCases) { strategy in
                Text(loc.localizedKey(strategy.localizationKey)).tag(strategy)
            }
        }
        .annotation {
            switch manager.rehideStrategy {
            case .smart:
                Text(loc.localized(.smartDetail))
            case .timed:
                Text(loc.localized(.timedDetail))
            case .focusedApp:
                Text(loc.localized(.focusedAppDetail))
            }
        }
    }

    @ViewBuilder
    private var autoRehideOptions: some View {
        Toggle(loc.localized(.autoRehide), isOn: manager.bindings.autoRehide)
        if manager.autoRehide {
            if case .timed = manager.rehideStrategy {
                VStack {
                    rehideStrategyPicker
                    IceSlider(
                        LocalizedStringKey(rehideIntervalLabel),
                        value: manager.bindings.rehideInterval,
                        in: 0...30,
                        step: 1
                    )
                }
            } else {
                rehideStrategyPicker
            }
        }
    }

    /// Apply menu bar spacing offset.
    private func applyOffset() {
        isApplyingOffset = true
        manager.itemSpacingOffset = tempItemSpacingOffset
        Task {
            do {
                try await appState.spacingManager.applyOffset()
            } catch {
                let alert = NSAlert(error: error)
                alert.runModal()
            }
            isApplyingOffset = false
        }
    }

    /// Reset menu bar spacing offset to default.
    private func resetOffsetToDefault() {
        tempItemSpacingOffset = 0
        manager.itemSpacingOffset = tempItemSpacingOffset
        applyOffset()
    }
}
