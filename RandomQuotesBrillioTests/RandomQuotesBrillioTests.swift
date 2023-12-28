//
//  RandomQuotesBrillioTests.swift
//  RandomQuotesBrillioTests
//
//  Created by Hiram Castro on 26/12/23.
//

import XCTest
@testable import RandomQuotesBrillio

final class RandomQuotesBrillioTests: XCTestCase {
    
    func test_deliversQuoteDataForValidURL() {
        let networkServiceMock = NetworkServiceMock()
        let sut = QuotesUseCase(networkService: networkServiceMock)
        
        let exp = expectation(description: "waiting for response")
        
        sut.fetchQuote(from: mockAPI.quoteURL) { result in
            switch result {
            case .success(let model):
                XCTAssertNotNil(model)
            case .failure(let error):
                XCTAssertNil(error)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_deliversValidQuoteAndAuthorForValidURL() {
        let networkServiceMock = NetworkServiceMock()
        let usecase = QuotesUseCase(networkService: networkServiceMock)
        let sut = QuoteVM(useCase: usecase)
        
        let exp = expectation(description: "waiting for response")
        
        sut.fetchQuote { result in
            switch result {
            case .success(let quote):
                XCTAssertNotNil(quote)
            case .failure(let error):
                XCTAssertNil(error)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_deliversErrorForInvalidURL() {
        let networkServiceMock = NetworkServiceMock()
        let sut = QuotesUseCase(networkService: networkServiceMock)
        
        let exp = expectation(description: "waiting for response")
        
        sut.fetchQuote(from: mockAPI.invalidURL) { result in
            switch result {
            case .success(let model):
                XCTAssertNil(model)
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
}

enum mockAPI {
    case authorURL(slug:String)
    case quoteURL
    case invalidURL
}

extension mockAPI: EndPoint {
    
    var path: String {
        switch self {
        case .quoteURL:
            return "http://a-valid-quote-url.com"
        case .authorURL:
            return "https://api.quotable.io/authors/slug/\(parameters["slug"] ?? "")"
        case .invalidURL:
            return "http://a-invalid-url.com"
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case .quoteURL:
            return [:]
        case let .authorURL(slug):
            return ["slug": slug]
        case .invalidURL:
            return [:]
        }
    }
    
    var request: URLRequest? {
        guard var components = URLComponents(string: path) else { return nil }
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        guard let url = components.url else { return nil }
        return URLRequest(url: url)
    }
}


class NetworkServiceMock: NetworkServiceProtocol {
    func fetchData(from endpoint: RandomQuotesBrillio.EndPoint,
                    completion: @escaping (RandomQuotesBrillio.HTTPClientResult) -> Void) {
        
        if endpoint.path == "http://a-valid-quote-url.com" {
            let quotesData: [String:Any] = [
                "_id": "d5mCJQDeQb", "content": "A poem begins in delight and ends in wisdom.", "author": "Robert Frost", "authorSlug" : "charles-dickens"
            ]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: quotesData, options: .prettyPrinted) else {
                  print("Something is wrong while converting dictionary to JSON data.")
                completion(.failure(NetworkError.genericError))
                return
               }
            completion(.success(jsonData, HTTPURLResponse(url: URL(string: mockAPI.quoteURL.path)!,
                                                          statusCode: 200,
                                                          httpVersion: nil,
                                                          headerFields: nil)!))
        } else if endpoint.path == "http://a-invalid-url.com" {
            let error = NSError(domain: "", code: 500)
            completion(.failure(error))
        }
        
    }
    
    
}
