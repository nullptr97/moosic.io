//
//  Authorizator.swift
//  MoosicIO
//
//  Created by Ярослав Стрельников on 09.11.2020.
//

import Foundation
import UIKit

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case connect = "CONNECT"
}

protocol Authorizator: AnyObject {
    func getSavedToken(sessionId: String) -> InvalidatableToken?
    func authorize(login: String, password: String, sessionId: String, revoke: Bool) async throws -> InvalidatableToken
    func authorize(login: String, password: String, sessionId: String, revoke: Bool, captchaSid: String?, captchaKey: String?) async throws -> InvalidatableToken
    func authorize(login: String, password: String, sessionId: String, revoke: Bool, code: Int?, forceSms: Int) async throws -> InvalidatableToken
    func reset(sessionId: String) -> InvalidatableToken?
}

final class AuthorizatorImpl: Authorizator {
    private let queue = DispatchQueue(label: "MoosicIO.authorizatorQueue")
    private let directAuthUrl: String = "https://oauth.vk.com/token?"
    
    private let appId: String
    private var tokenStorage: TokenStorage
    private weak var tokenMaker: TokenMaker?
    private weak var delegate: MoosicIOAuthorizatorDelegate?
    
    private(set) var vkAppToken: InvalidatableToken?
    private var requestTimeout: TimeInterval = 10
    
    init(appId: String, delegate: MoosicIOAuthorizatorDelegate?, tokenStorage: TokenStorage, tokenMaker: TokenMaker) {
        self.appId = appId
        self.delegate = delegate
        self.tokenStorage = tokenStorage
        self.tokenMaker = tokenMaker
    }
    
    func authorize(login: String, password: String, sessionId: String, revoke: Bool) async throws -> InvalidatableToken {
        defer { vkAppToken = nil }
        
        return try await authorize(login: login, password: password, sessionId: sessionId)
    }
    
    func authorize(login: String, password: String, sessionId: String, revoke: Bool, captchaSid: String?, captchaKey: String?) async throws -> InvalidatableToken {
        defer { vkAppToken = nil }
        
        return try await authorize(login: login, password: password, sessionId: sessionId, captchaSid: captchaSid, captchaKey: captchaKey)
    }

    func authorize(login: String, password: String, sessionId: String, revoke: Bool, code: Int?, forceSms: Int = 1) async throws -> InvalidatableToken {
        defer { vkAppToken = nil }
        
        return try await authorize(login: login, password: password, sessionId: sessionId, code: code, forceSms: forceSms)
    }
    
    func getSavedToken(sessionId: String) -> InvalidatableToken? {
        return queue.sync {
            tokenStorage.getFor(sessionId: sessionId)
        }
    }
    
    func reset(sessionId: String) -> InvalidatableToken? {
        return queue.sync {
            tokenStorage.removeFor(sessionId: sessionId)
            return nil
        }
    }
    
    private func getToken(from sessionId: String, authData: AuthData) async throws -> InvalidatableToken {
        switch authData {
        case .sessionInfo(silentToken: let st, silentTokenUuid: let stu, silentTokenTtl: let stt, trustedHash: let th):
            let queryItems: [URLQueryItem] = await [
                URLQueryItem(name: "device_id", value: UIDevice.current.identifierForVendor!.uuidString),
                URLQueryItem(name: "device_os", value: "iOS"),
                URLQueryItem(name: "silent_token", value: st),
                URLQueryItem(name: "uuid", value: stu)
            ]
            
            var urlComponents = URLComponents(string: "https://api.moosic.io/oauth/vkconnect/vk/token?")
            urlComponents?.queryItems = queryItems
            
            var request = URLRequest(url: urlComponents?.url ?? URL(string: directAuthUrl)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
            request.httpMethod = HTTPMethod.get.rawValue
            
            let task = try await NMURLSession.session.data(for: request)
            
            let response = JSON(task.0)
            let error = response["error"]
            if error != JSON.null {
                throw VKError.authorizationFailed
            } else {
                let token = try self.makeToken(accessToken: response["access_token"].stringValue, silentToken: st, silentTokenUuid: stu, silentTokenTtl: stt, trustedHash: th)
                try self.tokenStorage.save(token, for: sessionId)
                return token
            }
        }
    }

    private func makeToken(accessToken: String, silentToken: String, silentTokenUuid: String, silentTokenTtl: String, trustedHash: String) throws -> InvalidatableToken {
        guard let tokenMaker = tokenMaker else {
            throw VKError.weakObjectWasDeallocated
        }
        
        return tokenMaker.token(accessToken: accessToken, silentToken: silentToken, silentTokenUuid: silentTokenUuid, silentTokenTtl: silentTokenTtl, trustedHash: trustedHash)
    }
    
    private var settings: String {
        return "all"
    }
    
    func authorize(login: String, password: String, sessionId: String, captchaSid: String? = nil, captchaKey: String? = nil, code: Int? = nil, forceSms: Int = 1) async throws -> InvalidatableToken {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "grant_type", value: "password"),
            URLQueryItem(name: "client_id", value: Constants.appId),
            URLQueryItem(name: "client_secret", value: Constants.clientSecret),
            URLQueryItem(name: "username", value: login),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "v", value: "5.174"),
            URLQueryItem(name: "force_sms", value: "\(forceSms)"),
            URLQueryItem(name: "scope", value: settings),
            URLQueryItem(name: "lang", value: "ru"),
            await URLQueryItem(name: "device_id", value: UIDevice.current.identifierForVendor!.uuidString)
        ]
        
        if let captchaKey = captchaKey, let captchaSid = captchaSid {
            queryItems.append(URLQueryItem(name: "captcha_key", value: captchaKey))
            queryItems.append(URLQueryItem(name: "captcha_sid", value: captchaSid))
        }

        if let code = code {
            queryItems.append(URLQueryItem(name: "code", value: "\(code)"))
        }
        
        if forceSms == 1 {
            queryItems.append(URLQueryItem(name: "forse_sms", value: "1"))
        }
        
        var urlComponents = URLComponents(string: directAuthUrl)
        urlComponents?.queryItems = queryItems
        
        var request = URLRequest(url: urlComponents?.url ?? URL(string: directAuthUrl)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
        request.httpMethod = HTTPMethod.get.rawValue
        
        let task = try await NMURLSession.session.data(for: request)
        
        let response = JSON(task.0)
        let error = response["error"]
        if error != JSON.null {
            switch error.stringValue {
            case ErrorType.capthca.rawValue:
                throw VKError.needCaptcha(captchaImg: response["captcha_img"].stringValue, captchaSid: response["captcha_sid"].stringValue)
            case ErrorType.incorrectLoginPassword.rawValue:
                throw VKError.incorrectLoginPassword
            case ErrorType.needValidation.rawValue:
                throw VKError.needValidation(validationType: response["validation_type"].stringValue, phoneMask: response["phone_mask"].stringValue, redirectUri: response["redirect_uri"].string)
            default:
                if let apiError = ApiError(errorJSON: response) {
                    throw VKError.api(apiError)
                } else {
                    throw VKError.authorizationFailed
                }
            }
        } else {
            let data = AuthData.sessionInfo(silentToken: response["silent_token"].stringValue, silentTokenUuid: response["silent_token_uuid"].stringValue, silentTokenTtl: response["silent_token_ttl"].stringValue, trustedHash: response["trusted_hash"].stringValue)
            
            let token = try await getToken(from: sessionId, authData: data)
            return token
        }
    }
}
