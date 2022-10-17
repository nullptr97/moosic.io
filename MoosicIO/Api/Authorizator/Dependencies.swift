//
//  Dependencies.swift
//  MoosicIO
//
//  Created by Ярослав Стрельников on 09.11.2020.
//

import Foundation
import UIKit

protocol Dependencies:
    DependenciesHolder,
    TokenMaker,
    SessionMaker { }

protocol DependenciesHolder: SessionsHolderHolder, AuthorizatorHolder {
    init(delegate: MoosicIODelegate?, bundleName: String?, configPath: String?)
}

extension DependenciesHolder {
    init(delegate: MoosicIODelegate?) {
        self.init(delegate: delegate, bundleName: nil, configPath: nil)
    }
}

protocol SessionsHolderHolder: AnyObject {
    var sessionsHolder: SessionsHolder & SessionSaver { get }
}

protocol AuthorizatorHolder: AnyObject {
    var authorizator: Authorizator { get }
}

typealias VKStoryboard = UIStoryboard

final class DependenciesImpl: Dependencies {
    private weak var delegate: MoosicIODelegate?
    private let customBundleName: String?
    private let customConfigPath: String?
    
    private let uiSyncQueue = DispatchQueue(label: "MoosicIO.uiSyncQueue")
    
    private lazy var connectionObserver: ConnectionObserver? = {
        guard let reachability = Reachability() else { return nil }
        
        let appStateCenter = NotificationCenter.default
        let activeNotificationName = UIApplication.didBecomeActiveNotification
        let inactiveNotificationName = UIApplication.didEnterBackgroundNotification
        
        return ConnectionObserverImpl(
            appStateCenter: appStateCenter,
            reachabilityCenter: NotificationCenter.default,
            reachability: reachability,
            activeNotificationName: activeNotificationName,
            inactiveNotificationName: inactiveNotificationName,
            reachabilityNotificationName: ReachabilityChangedNotification
        )
    }()
    
    init(delegate: MoosicIODelegate?, bundleName: String?, configPath: String?) {
        self.delegate = delegate
        self.customBundleName = bundleName
        self.customConfigPath = configPath
    }
    
    lazy var sessionsHolder: SessionsHolder & SessionSaver = {
        atomicSessionHolder.modify {
            $0 ?? SessionsHolderImpl(
                sessionMaker: self,
                sessionsStorage: self.sessionsStorage
            )
        }
        
        guard let holder = atomicSessionHolder.unwrap() else {
            fatalError("Holder was not created")
        }
        
        return holder
    }()

    private var atomicSessionHolder = Atomic<(SessionsHolder & SessionSaver)?>(nil)
    
    lazy var sessionsStorage: SessionsStorage = {
        SessionsStorageImpl(
            fileManager: FileManager(),
            bundleName: self.bundleName,
            configName: self.customConfigPath ?? "MoosicIOState"
        )
    }()
    
    private lazy var bundleName: String = {
        customBundleName ?? Bundle.main.infoDictionary?[String(kCFBundleNameKey)] as? String ?? "MoosicIO"
    }()
    
    func session(id: String, sessionSaver: SessionSaver) -> Session {
        return SessionImpl(id: id, authorizator: sharedAuthorizator, sessionSaver: sessionSaver, delegate: delegate)
    }
    
    var authorizator: Authorizator {
        get { return sharedAuthorizator }
        set { sharedAuthorizator = newValue }
    }
    
    private lazy var sharedAuthorizator: Authorizator = {
        let tokenStorage = TokenStorageImpl(serviceKey: bundleName + "_Token")
        
        return AuthorizatorImpl(delegate: delegate, tokenStorage: tokenStorage, tokenMaker: self)
    }()
    
    func token(accessToken: String, silentToken: String, silentTokenUuid: String, silentTokenTtl: String, trustedHash: String) -> InvalidatableToken {
        return TokenImpl(accessToken: accessToken, silentToken: silentToken, silentTokenUuid: silentTokenUuid, silentTokenTtl: silentTokenTtl, trustedHash: trustedHash)
    }
}
