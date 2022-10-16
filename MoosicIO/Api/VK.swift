import Foundation

/// MoosicIO entry point
public final class VK {
    public static func setUp(appId: String, delegate: MoosicIODelegate, bundleName: String? = nil, configPath: String? = nil) {
        guard dependencies == nil else {
            return
        }

        dependencies = dependenciesType.init(appId: appId, delegate: delegate, bundleName: bundleName, configPath: configPath)
    }
    
    /// Returns MoosicIO user sessions
    public static var sessions: SessionsHolder {
        guard let sessionsHolder = dependencies?.sessionsHolder else {
            fatalError("You must call VK.setUp function to start using MoosicIO!")
        }
        
        return sessionsHolder
    }

    /// Does `VK.setUp` already called
    public static var needToSetUp: Bool {
        return dependencies?.sessionsHolder == nil
    }

    /// Free up all MoosicIO's resources and release memory
    /// Call it only if you won't interact with the library anymore
    /// If you'll need to work with the library again after calling this method, you should call setUp
    public static func release() {
        dependencies = nil
    }

    static var dependenciesType: DependenciesHolder.Type = DependenciesImpl.self
    private static var dependencies: DependenciesHolder?
}
