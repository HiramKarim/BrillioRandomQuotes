//
//  NetworkServiceProtocol.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 26/12/23.
//

import Foundation

public protocol EndPoint {
    var path: String { get }
    var request: URLRequest? { get }
    var parameters: [String:Any] { get }
}

enum API {
    case quotes
    case author(slug:String)
}

extension API: EndPoint {
    
    var path: String {
        switch self {
        case .quotes:
            return "https://api.quotable.io/random"
        case .author:
            return "https://api.quotable.io/authors/slug/\(parameters["slug"] ?? "")"
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case .quotes:
            return [:]
        case let .author(slug):
            return ["slug": slug]
        }
    }
    
    var request: URLRequest? {
        guard var components = URLComponents(string: path) else { return nil }
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        guard let url = components.url else { return nil }
        return URLRequest(url: url)
    }
}


enum NetworkError: Error {
    case genericError
}

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

protocol NetworkServiceProtocol {
    func fetchData(from endpoint: EndPoint, completion: @escaping (HTTPClientResult) -> Void)
}
