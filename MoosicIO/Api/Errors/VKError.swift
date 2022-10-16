//
//  VKError.swift
//  MoosicIO
//
//  Created by Ярослав Стрельников on 09.11.2020.
//

import Foundation

/// Represents any error which MoosicIO can return
public indirect enum VKError: Error {
    // MARK: - Any error wrapper
    case unknown(Error)
    case noAccessToken(String)
    case emptyJSON(String)
    case fullStack
    
    // MARK: - Errors from VK API
    case api(ApiError)
    
    // MARK: - Session errors
    case cantSaveToKeychain(Int32)
    case vkDelegateNotFound
    case cantParseTokenInfo(String)
    case sessionAlreadyDestroyed(Session)
    case sessionAlreadyAuthorized(Session)
    case sessionIsNotAuthorized(Session)

    // MARK: - Request errors
    case unexpectedResponse
    case jsonNotParsed(Error)
    case errorJsonParse(String)
    case urlRequestError(Error)
    case captchaResultIsNil
    case wrongUrl
    case cantAwaitOnMainThread
    case cantAwaitRequestWithSettedCallbacks
    
    // MARK: - UI Errors
    case cantBuildWebViewUrl(String)
    case cantBuildVKAppUrl(String)
    case captchaPresenterTimedOut
    case cantMakeCapthaImageUrl(String)
    case cantLoadCaptchaImage(Error)
    case cantLoadCaptchaImageWithUnknownReason
    case webPresenterTimedOut
    case webPresenterResultIsNil
    case webControllerError(Error)
    case authorizationUrlIsNil
    case authorizationDenied
    case authorizationCancelled
    case authorizationFailed
    case captchaWasDismissed
    case sharingWasDismissed
    
    case userDeactivated(reason: String)
    case sessionInvalidate(reason: String)
    
    case weakObjectWasDeallocated
    
    case needCaptcha(captchaImg: String, captchaSid: String)
    case incorrectLoginPassword
    case needValidation(validationType: String, phoneMask: String, redirectUri: String?)
    
    func toApi() -> ApiError? {
        switch self {
        case let .api(error):
            return error
        default:
            return nil
        }
    }
}
