//
//  Session.swift
//  MoosicIO
//
//  Created by Ярослав Стрельников on 09.11.2020.
//

import Foundation
import UIKit

protocol ApiErrorExecutor {
    func captcha(rawUrlToImage: String, dismissOnFinish: Bool) throws
}

protocol SessionMaker: AnyObject {
    func session(id: String, sessionSaver: SessionSaver) -> Session
}

public enum SessionState: Int, Comparable, Codable {
    case destroyed = -1
    case initiated = 0
    case authorized = 1
    case deactivated = 8
    
    public static func == (lhs: SessionState, rhs: SessionState) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public static func < (lhs: SessionState, rhs: SessionState) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

import Foundation

/// VK user session
public protocol Session: AnyObject {
    /// Internal MoosicIO session identifier
    var id: String { get }
    /// Current session configuration.
    var state: SessionState { get }
    /// token of current user
    var accessToken: Token? { get }
    
    var token: InvalidatableToken? { get }
    
    var apiErrorHandler: ApiErrorHandler? { get }
    
    /// Log in user with oAuth or VK app
    /// - parameter onSuccess: clousure which will be executed when user sucessfully logged.
    /// Returns info about logged user.
    /// - parameter onError: clousure which will be executed when logging failed.
    /// Returns cause of failure.
    func logIn(login: String, password: String) async throws
    func logIn(login: String, password: String, captchaSid: String?, captchaKey: String?) async throws
    func logIn(login: String, password: String, code: Int?, forceSms: Int) async throws
    /// Log out user, remove all data and destroy current session
    func logOut(_ block: @escaping () -> (Void))
    func logOut()
    
    func throwIfDeactivated() throws
    func throwIfInvalidateSession() throws
}

protocol DestroyableSession: Session {
    func destroy()
    func destroy(_ block: @escaping () -> (Void))
}

public final class SessionImpl: Session, DestroyableSession, ApiErrorExecutor {
    public var state: SessionState {
        if id.isEmpty || token == nil {
            return .destroyed
        } else if token?.silentToken != "invalidate" {
            return .authorized
        } else if ((token?.silentToken.contains("_deactivate")) != nil) {
            return .deactivated
        } else {
            return .initiated
        }
    }
    
    public internal(set) var id: String
    
    public internal(set) var token: InvalidatableToken?
    
    public var accessToken: Token? {
        return token
    }

    private weak var sessionSaver: SessionSaver?
    private let authorizator: Authorizator
    private weak var delegate: MoosicIOSessionDelegate?
    public var apiErrorHandler: ApiErrorHandler?
    private let gateQueue = DispatchQueue(label: "MoosicIO.sessionQueue")

    init(id: String, authorizator: Authorizator, sessionSaver: SessionSaver, delegate: MoosicIOSessionDelegate?) {
        self.id = id
        self.authorizator = authorizator
        self.sessionSaver = sessionSaver
        self.delegate = delegate
        self.token = authorizator.getSavedToken(sessionId: id)
        self.apiErrorHandler = ApiErrorHandlerImpl(executor: self)
    }
    
    public func logIn(login: String, password: String) async throws {
        token = try await authorizator.authorize(login: login, password: password, sessionId: id, revoke: true)
    }
    
    public func logIn(login: String, password: String, captchaSid: String?, captchaKey: String?) async throws {
        token = try await authorizator.authorize(login: login, password: password, sessionId: id, revoke: true, captchaSid: captchaSid, captchaKey: captchaKey)
    }

    public func logIn(login: String, password: String, code: Int?, forceSms: Int = 0) async throws {
        token = try await authorizator.authorize(login: login, password: password, sessionId: id, revoke: true, code: code, forceSms: forceSms)
    }
    
    public func logOut(_ block: @escaping () -> (Void)) {
        delegate?.tokenRemoved(for: id)
        destroy(block)
    }
    
    public func logOut() {
        delegate?.tokenRemoved(for: id)
        destroy()
    }

    private func throwIfDestroyed() throws {
        guard state > .destroyed else {
            throw VKError.sessionAlreadyDestroyed(self)
        }
    }
    
    public func throwIfDeactivated() throws {
        guard state > .authorized else {
            VK.sessions.default.logOut()
            throw VKError.userDeactivated(reason: "User deactivated")
        }
    }
    
    private func throwIfAuthorized() throws {
        guard state < .authorized else {
            throw VKError.sessionAlreadyAuthorized(self)
        }
    }
    
    private func throwIfNotAuthorized() throws {
        guard state >= .authorized else {
            throw VKError.sessionIsNotAuthorized(self)
        }
    }
    
    public func throwIfInvalidateSession() throws {
        VK.sessions.default.logOut()
        throw VKError.authorizationFailed
    }
    
    func destroy() {
        gateQueue.sync { unsafeDestroy() }
    }
    
    func destroy(_ block: @escaping () -> (Void)) {
        gateQueue.sync { unsafeDestroy(block) }
    }
    
    func captcha(rawUrlToImage: String, dismissOnFinish: Bool) throws {
        try throwIfDestroyed()
    }
    
    private func unsafeDestroy() {
        token = authorizator.reset(sessionId: id)
        id = ""
        updateUserId(userId: 0)
        sessionSaver?.saveState()
        sessionSaver?.removeSession()
    }
    
    private func unsafeDestroy(_ block: @escaping () -> (Void)) {
        token = authorizator.reset(sessionId: id)
        id = ""
        updateUserId(userId: 0)
        sessionSaver?.saveState()
        sessionSaver?.removeSession()
        block()
    }
    
    private func updateUserId(userId: Int) {
        currentUserId = userId
    }
}

struct EncodedSession: Codable {
    let isDefault: Bool
    let id: String
    let token: String
}

public protocol SessionsHolder: AnyObject {
    /// Default VK user session
    var `default`: Session { get }
    
    var all: [Session] { get }
}

protocol SessionSaver: AnyObject {
    func saveState()
    func destroy(session: Session) throws
    func removeSession()
}

public final class SessionsHolderImpl: SessionsHolder, SessionSaver {
    private unowned var sessionMaker: SessionMaker
    private let sessionsStorage: SessionsStorage
    private var sessions = NSHashTable<AnyObject>(options: .strongMemory)
    
    public var `default`: Session {
        if let realDefault = storedDefault, realDefault.state > .destroyed {
            return realDefault
        }
        
        sessions.remove(storedDefault)
        return makeSession(makeDefault: true)
    }
    
    private weak var storedDefault: Session?
    
    public var all: [Session] {
        return sessions.allObjects.compactMap { $0 as? Session }
    }
    
    init(sessionMaker: SessionMaker, sessionsStorage: SessionsStorage) {
        self.sessionMaker = sessionMaker
        self.sessionsStorage = sessionsStorage
        restoreState()
    }
    
    public func make() -> Session {
        return makeSession()
    }
    
    @discardableResult
    private func makeSession(makeDefault: Bool = false) -> Session {
        let sessionId = MD5.MD5(generatedSessionId).uppercased()
        let session = sessionMaker.session(id: sessionId, sessionSaver: self)
        
        sessions.add(session)
        
        if makeDefault {
            storedDefault = session
        }
        
        saveState()
        return session
    }
    
    private var generatedSessionId: String {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let randomInt = "\(Int.random(in: 11...11))"
        let sessionId = "\(deviceId)_\(randomInt)"
        return sessionId
    }
    
    public func destroy(session: Session) throws {
        if session.state == .destroyed {
            throw VKError.sessionAlreadyDestroyed(session)
        }
        
        (session as? DestroyableSession)?.destroy()
        sessions.remove(session)
    }
    
    public func markAsDefault(session: Session) throws {
        if session.state == .destroyed {
            throw VKError.sessionAlreadyDestroyed(session)
        }
        
        self.storedDefault = session
        saveState()
    }
    
    func saveState() {
        let encodedSessions = self.all.map { EncodedSession(isDefault: $0.id == storedDefault?.id, id: $0.id, token: $0.accessToken?.silentToken ?? "invalidate") }.filter { !$0.id.isEmpty }
        
        do {
            try self.sessionsStorage.save(sessions: encodedSessions)
        }
        catch let error {
            print("MoosicIO: Sessions not saved with an error: \(error)")
        }
    }
    
    private func restoreState() {
        do {
            let restored = try sessionsStorage.restore()
            
            restored.filter { !$0.id.isEmpty }.forEach { makeSession(makeDefault: $0.isDefault) }
        }
        catch let error {
            print("MoosicIO: Sessions not rerstored with an error: \(error)")
        }
    }
    
    public func removeSession() {
        let encodedSessions = all.map { EncodedSession(isDefault: $0.id == storedDefault?.id, id: $0.id, token: $0.accessToken?.silentToken ?? "invalidate") }.filter { !$0.id.isEmpty }
        
        do {
            try self.sessionsStorage.remove(sessions: encodedSessions)
        } catch {
            print("Sessions not saved with an error: \(error)")
        }
    }
}
