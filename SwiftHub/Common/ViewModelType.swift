//
//  ViewModelType.swift
//  SwiftHub
//
//  Created by Khoren Markosyan on 6/30/18.
//  Copyright © 2018 Khoren Markosyan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}

class ViewModel: NSObject {

    let provider: SwiftHubAPI

    var page = 1
    //加载中
    let loading = ActivityIndicator()
    let headerLoading = ActivityIndicator()
    let footerLoading = ActivityIndicator()

    let error = ErrorTracker()
    //解析出错
    let parsedError = PublishSubject<ApiError>()

    init(provider: SwiftHubAPI) {
        self.provider = provider
        super.init()
        // 错误
        error.asObservable().map { (error) -> ApiError? in
            do {
                let errorResponse = error as? MoyaError
                //转JSON
                if let body = try errorResponse?.response?.mapJSON() as? [String: Any],
                    let errorResponse = Mapper<ErrorResponse>().map(JSON: body) {
                    return ApiError.serverError(response: errorResponse)
                }
            } catch {
                print(error)
            }
            return nil
        }.filterNil().bind(to: parsedError).disposed(by: rx.disposeBag)

        error.asDriver().drive(onNext: { (error) in
            //错误日志
            logError("\(error)")
        }).disposed(by: rx.disposeBag)
    }

    deinit {
        logDebug("\(type(of: self)): Deinited")
        logResourcesCount()
    }
}
