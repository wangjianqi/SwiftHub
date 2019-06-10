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

    //协议
    let provider: SwiftHubAPI

    var page = 1

    let loading = ActivityIndicator()
    let headerLoading = ActivityIndicator()
    let footerLoading = ActivityIndicator()

    let error = ErrorTracker()
    //解析错误
    let parsedError = PublishSubject<ApiError>()

    //构造方法
    init(provider: SwiftHubAPI) {
        self.provider = provider
        super.init()

        error.asObservable().map { (error) -> ApiError? in
            do {
                let errorResponse = error as? MoyaError
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
            //输出错误
            logError("\(error)")
        }).disposed(by: rx.disposeBag)
    }

    deinit {
        logDebug("\(type(of: self)): Deinited")
        logResourcesCount()
    }
}
