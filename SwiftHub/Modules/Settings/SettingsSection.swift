//
//  SettingsSection.swift
//  SwiftHub
//
//  Created by Khoren Markosyan on 7/23/18.
//  Copyright © 2018 Khoren Markosyan. All rights reserved.
//

import Foundation
import RxDataSources

enum SettingsSection {
    case setting(title: String, items: [SettingsSectionItem])
}

enum SettingsSectionItem {
    // Account
    case profileItem(viewModel: UserCellViewModel)
    case logoutItem(viewModel: SettingCellViewModel)

    // Preferences
    case bannerItem(viewModel: SettingSwitchCellViewModel)
    case nightModeItem(viewModel: SettingSwitchCellViewModel)
    case themeItem(viewModel: SettingCellViewModel)
    case languageItem(viewModel: SettingCellViewModel)
    case contactsItem(viewModel: SettingCellViewModel)
    case removeCacheItem(viewModel: SettingCellViewModel)

    // Support
    case acknowledgementsItem(viewModel: SettingCellViewModel)
    case whatsNewItem(viewModel: SettingCellViewModel)
}

extension SettingsSection: SectionModelType {
    //指定类型
    typealias Item = SettingsSectionItem

    var title: String {
        switch self {
        case .setting(let title, _): return title
        }
    }

    //实现items
    var items: [SettingsSectionItem] {
        switch  self {
        case .setting(_, let items): return items.map {$0}
        }
    }

    //实现init方法
    init(original: SettingsSection, items: [Item]) {
        switch original {
        case .setting(let title, let items): self = .setting(title: title, items: items)
        }
    }
}
