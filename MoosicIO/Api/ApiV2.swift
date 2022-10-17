//
//  ApiV2.swift
//  VKM
//
//  Created by Ярослав Стрельников on 05.03.2021.
//

import Foundation

extension NMURLSession: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print(data.json())
    }
}

open class NMURLSession: NSObject {
    private static let shared = NMURLSession()

    static var session: URLSession {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: NMURLSession.shared, delegateQueue: .main)
        return session
    }
    
    static var authorizedSession: URLSession {
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

public protocol Parseable {
    associatedtype ParseableObject
    
    static func parse(_ json: JSON) -> ParseableObject
}

public var _dataField: String = ""

public struct Response<T>: Parseable where T: Parseable {
    var data: DataClass<T>
    var extra: Extra
    
    public static func parse(_ json: JSON) -> Response<T> {
        let response = Response(data: DataClass<T>.parse(json["data"]), extra: Extra.parse(json["extra"]))
        return response
    }
}

public struct DataClass<T>: Parseable where T: Parseable {
    var objects: [T]
    
    public static func parse(_ json: JSON) -> DataClass<T> {
        let data = DataClass(objects: json[_dataField].arrayValue.compactMap { T.parse($0) as? T } )
        return data
    }
}

// MARK: - Extra
public struct Extra: Parseable {
    var offset: Int
    
    public static func parse(_ json: JSON) -> Extra {
        let extra = Extra(offset: json["offset"].intValue)
        return extra
    }
}

open class Api<T>: NSObject where T: Parseable {
    public static func exec(_ method: String, dataField: String, parameters: [String: String] = [:], requestMethod: HTTPMethod) async throws -> T {
        _dataField = dataField
        
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
        
        let result = try await NMURLSession.authorizedSession.data(for: request)
        let parsedObject = T.parse(JSON(result.0))
        
        if parsedObject is T {
            return parsedObject as! T
        } else {
            throw "\(T.self) is not parseable object"
        }
    }
}

open class DecodableApi<T>: NSObject where T: Codable {
    public static func exec(_ method: String, dataField: String, parameters: [String: String] = [:], requestMethod: HTTPMethod) async throws -> T {
        _dataField = dataField
        
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
        
        let result = try await NMURLSession.authorizedSession.data(for: request)
        
        return try JSONDecoder().decode(T.self, from: result.0)
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
