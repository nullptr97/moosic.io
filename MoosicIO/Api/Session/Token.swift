//
//  Token.swift
//  MoosicIO
//
//  Created by Ярослав Стрельников on 09.11.2020.
//

import Foundation

protocol TokenMaker: AnyObject {
    func token(accessToken: String, silentToken: String, silentTokenUuid: String, silentTokenTtl: String, trustedHash: String) -> InvalidatableToken
}

public protocol Token: AnyObject {
    var accessToken: String { get set }
    var silentToken: String { get }
    var silentTokenUuid: String { get }
    var silentTokenTtl: String { get }
    var trustedHash: String { get }
}

public protocol InvalidatableToken: NSCoding, Token {
    func invalidate()
}

final class TokenImpl: NSObject, InvalidatableToken {
    public internal(set) var accessToken: String
    public internal(set) var silentToken: String
    public internal(set) var silentTokenUuid: String
    public internal(set) var silentTokenTtl: String
    public internal(set) var trustedHash: String
    
    init(accessToken: String, silentToken: String, silentTokenUuid: String, silentTokenTtl: String, trustedHash: String) {
        self.silentToken = silentToken
        self.accessToken = accessToken
        self.silentTokenUuid = silentTokenUuid
        self.silentTokenTtl = silentTokenTtl
        self.trustedHash = trustedHash
    }
    
    func invalidate() {
        accessToken = ""
        silentToken = ""
        silentTokenUuid = ""
        silentTokenTtl = ""
        trustedHash = ""
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(accessToken, forKey: "accessToken")
        aCoder.encode(silentToken, forKey: "silentToken")
        aCoder.encode(silentTokenUuid, forKey: "silentTokenUuid")
        aCoder.encode(silentTokenTtl, forKey: "silentTokenTtl")
        aCoder.encode(trustedHash, forKey: "trustedHash")
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let accessToken = aDecoder.decodeObject(forKey: "accessToken") as? String else { return nil }
        guard let silentToken = aDecoder.decodeObject(forKey: "silentToken") as? String else { return nil }
        guard let silentTokenUuid = aDecoder.decodeObject(forKey: "silentTokenUuid") as? String else { return nil }
        guard let silentTokenTtl = aDecoder.decodeObject(forKey: "silentTokenTtl") as? String else { return nil }
        guard let trustedHash = aDecoder.decodeObject(forKey: "trustedHash") as? String else { return nil }
        
        self.accessToken = accessToken
        self.silentToken = silentToken
        self.silentTokenUuid = silentTokenUuid
        self.silentTokenTtl = silentTokenTtl
        self.trustedHash = trustedHash
    }
}
