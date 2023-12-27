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
}

enum API {
    case quotes
    case author
}

extension API: EndPoint {
    
    var path: String {
        switch self {
        case .quotes:
            return "https://api.quotable.io/random"
        case .author:
            return "https://api.quotable.io/search/authors?query={author}"
        }
    }
    
    var request: URLRequest? {
        guard let url = URL(string: path) else { return nil }
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
    func fetchQuote(from endpoint: EndPoint, completion: @escaping (HTTPClientResult) -> Void)
}
