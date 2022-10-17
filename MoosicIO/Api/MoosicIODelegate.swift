//
//  MoosicIODelegate.swift
//  MoosicIO
//
//  Created by Ярослав Стрельников on 16.10.2022.
//

import Foundation

public typealias MoosicIODelegate = MoosicIOSessionDelegate & MoosicIOAuthorizatorDelegate

public protocol MoosicIOSessionDelegate: AnyObject {
    /// Called when MoosicIO attempts get access to user account
    /// Should return set of permission scopes
    /// parameter sessionId: MoosicIO session identifier
    func vkNeedsScopes(for sessionId: String) -> String
}

public protocol MoosicIOAuthorizatorDelegate: AnyObject {
    /// Called when user grant access and MoosicIO gets new session token
    /// Can be used for run MoosicIO requests and save session data
    /// parameter sessionId: MoosicIO session identifier
    func tokenCreated(for sessionId: String, token: String)

    /// Called when existing session token was expired and successfully refreshed
    /// Most likely here you do not do anything
    /// parameter sessionId: MoosicIO session identifier
    /// parameter info: Authorized user info
    func tokenUpdated(for sessionId: String, token: String)

    /// Called when user was logged out
    /// Use this point to cancel all MoosicIO requests and remove session data
    /// parameter sessionId: MoosicIO session identifier
    func tokenRemoved(for sessionId: String)
}

extension MoosicIOSessionDelegate {
    
    // Default dummy methods implementations
    // Allows using its optionally
    
    public func tokenCreated(for sessionId: String, token: String) {}
    public func tokenUpdated(for sessionId: String, token: String) {}
    public func tokenRemoved(for sessionId: String) {}
}
