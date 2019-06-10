//
//  ThemeCellViewModel.swift
//  SwiftHub
//
//  Created by Sygnoos9 on 9/15/18.
//  Copyright © 2018 Khoren Markosyan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ThemeCellViewModel {

    //颜色
    let title: Driver<String>
    let imageColor: Driver<UIColor>

    let theme: ColorTheme

    init(with theme: ColorTheme) {
        self.theme = theme
        title = Driver.just(theme.title)
        imageColor = Driver.just(theme.color)
    }
}
