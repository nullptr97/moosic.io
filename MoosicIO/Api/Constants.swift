//
//  Constants.swift
//  Api
//
//  Created by Ярослав Стрельников on 19.10.2020.
//

import Foundation
import UIKit

var currentUserId: Int {
    get {
        UserDefaults.standard.integer(forKey: "userId")
    } set {
        UserDefaults.standard.set(newValue, forKey: "userId")
    }
}

public typealias UserAgent = String
typealias SettingInfo = (title: String, accessor: String, description: String)

public struct Constants {
    public static let appId: String = "6767438"
    public static let clientSecret: String = "ppBOmwQYYOMGulmaiPyK"

    public static var userAgent: UserAgent {
        return "Moosic/6.6.0 (com.music.vk; build:92; iOS 16.0.0) Alamofire/5.5.0"
    }
    
    public static var fileTypes = ["public.3gpp", "public.3gpp2", "public.audio", "public.mp3", "public.mpeg-4-audio", "com.apple.protected-​mpeg-4-audio", "public.ulaw-audio", "public.aifc-audio", "public.aiff-audio", "com.apple.coreaudio-​format", "public.directory", "public.folder"]
    
    public static var iosEventId: Int {
        get {
            UserDefaults.standard.integer(forKey: "iosEventId")
        } set {
            UserDefaults.standard.set(newValue, forKey: "iosEventId")
        }
    }
}
