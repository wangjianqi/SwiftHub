//
//  LanguageCellViewModel.swift
//  SwiftHub
//
//  Created by Sygnoos9 on 3/25/18.
//  Copyright © 2018 Khoren Markosyan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//cellViewModel
class LanguageCellViewModel {

    //
    let title: Driver<String>

    var language: String

    init(with language: String) {
        self.language = language
        //生成Driver
        title = Driver.just("\(displayName(forLanguage: language))")
    }
}

//显示的name
func displayName(forLanguage language: String) -> String {
    let local = Locale(identifier: language)
    if let displayName = local.localizedString(forIdentifier: language) {
        return displayName.capitalized(with: local)
    }
    return String()
}
