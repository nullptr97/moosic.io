//
//  ApiV2.swift
//  VKM
//
//  Created by Ярослав Стрельников on 05.03.2021.
//

import Foundation

enum TrackApiAction: String {
    case add = "add"
    case remove = "delete"
}

extension NMURLSession: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print(data.json())
    }
}

open class NMURLSession: NSObject {
    private static let shared = NMURLSession()

    static var session: URLSession {
        let config = URLSessionConfiguration.default
        
        guard let token = VK.sessions.default.accessToken?.accessToken else {
            return URLSession.shared
        }
        
        let headers: [String: String] = [
            "User-Agent" : Constants.userAgent,
            "X-Client-Version" : "6.6.0+92",
            "X-App-Id" : "iOS",
            "X-From" : UUID().uuidString,
            "Authorization" : "Bearer \(token)"
        ]
        
        config.httpAdditionalHeaders = headers
        
        let session = URLSession(configuration: config, delegate: NMURLSession.shared, delegateQueue: .main)
        return session
    }
}

class ApiV2: NSObject {
    static func execute(_ method: String, parameters: [String: String] = [:], requestMethod: HTTPMethod = .get, didSuccess: @escaping (JSON) -> (), didError: @escaping (VKError) -> ()) {
        var queryItems = [URLQueryItem]()
        
        if !parameters.isEmpty {
            for parameter in parameters {
                queryItems.append(URLQueryItem(name: parameter.key, value: "\(parameter.value)"))
            }
        }
        
        var urlComponents = URLComponents(string: "https://api.moosic.io/" + method)
        urlComponents?.queryItems = queryItems
        
        var request = URLRequest(url: urlComponents?.url ?? URL(string: "https://api.moosic.io/" + method)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
        request.httpMethod = requestMethod.rawValue
        
        NMURLSession.session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    didError(VKError.urlRequestError(error))
                }
            }
            
            if let data = data {
                if let apiError = ApiError(errorJSON: JSON(data)) {
                    DispatchQueue.main.async {
                        didError(VKError.api(apiError))
                    }
                } else {
                    let response = JSON(data)
                    DispatchQueue.main.async {
                        didSuccess(response)
                    }
                }
            }
        }.resume()
    }
}

public extension Data {
    func string(encoding: String.Encoding) -> String? {
        return String(data: self, encoding: encoding)
    }

    func jsonObject(options: JSONSerialization.ReadingOptions = []) throws -> Any {
        return try JSONSerialization.jsonObject(with: self, options: options)
    }
}

extension String {
    static var defaultApiVersion = "5.90"
}
