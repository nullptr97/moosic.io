//
//  Request.swift
//  Api
//
//  Created by Ярослав Стрельников on 19.10.2020.
//

import Foundation

extension Data {
    func json(has response: Bool = true) -> JSON {
        return response ? JSON(self)["response"] : JSON(self)
    }
}

enum ErrorType: String {
    case incorrectLoginPassword = "invalid_client"
    case capthca = "need_captcha"
    case needValidation = "need_validation"
}

enum AuthData {
    case sessionInfo(silentToken: String, silentTokenUuid: String, silentTokenTtl: String, trustedHash: String)
}
