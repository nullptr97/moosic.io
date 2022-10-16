//
//  File.swift
//  VKM
//
//  Created by Ярослав Стрельников on 30.03.2021.
//

import Foundation

public protocol ApiErrorHandler {
    func handle(error: ApiError, token: InvalidatableToken?) throws -> ApiErrorHandlerResult
}

public final class ApiErrorHandlerImpl: ApiErrorHandler {
    
    private let executor: ApiErrorExecutor
    
    init(executor: ApiErrorExecutor) {
        self.executor = executor
    }
    
    public func handle(error: ApiError, token: InvalidatableToken?) throws -> ApiErrorHandlerResult {
        return .invalidateToken
    }
}

public enum ApiErrorHandlerResult {
    case invalidateToken
    case deactivateToken
}
