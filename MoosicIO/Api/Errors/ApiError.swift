//
//  ApiError.swift
//  MoosicIO
//
//  Created by Ярослав Стрельников on 09.11.2020.
//

import Foundation

/// Represents Error recieved from VK API. More info - https://vk.com/dev/errors
public struct ApiError: Equatable {
    /// Error message
    public let message: String
    
    init?(_ json: JSON) {
        guard let errorMessage = json["error_description"].string else {
            return nil
        }
        
        message = errorMessage
    }
    
    init?(errorJSON: JSON) {
        guard let errorMessage = errorJSON["error_description"].string else {
            return nil
        }
        
        message = errorMessage
    }
    
    // Only for unit tests
    init(code: Int, otherInfo: [String: String] = [:]) {
        self.message = ""
    }
    
    var toVK: VKError {
        return .api(self)
    }
    
    public static func == (lhs: ApiError, rhs: ApiError) -> Bool {
        return lhs.message == rhs.message
    }
}
