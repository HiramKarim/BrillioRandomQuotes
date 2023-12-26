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
        
        sut.fetchQuote(from: mockAPI.validURL) { result in
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
    case validURL
    case invalidURL
}

extension mockAPI: EndPoint {
    var path: String {
        switch self {
        case .validURL:
            return "http://a-valid-url.com"
        case .invalidURL:
            return "http://a-invalid-url.com"
        }
    }
    
    var request: URLRequest? {
        guard let url = URL(string: path) else { return nil }
        return URLRequest(url: url)
    }
}


class NetworkServiceMock: NetworkServiceProtocol {
    func fetchQuote(from endpoint: RandomQuotesBrillio.EndPoint,
                    completion: @escaping (RandomQuotesBrillio.HTTPClientResult) -> Void) {
        
        if endpoint.path == "http://a-valid-url.com" {
            let quotesData: [String:Any] = [
                "_id": "d5mCJQDeQb", "content": "A poem begins in delight and ends in wisdom.", "author": "Robert Frost"
            ]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: quotesData, options: .prettyPrinted) else {
                  print("Something is wrong while converting dictionary to JSON data.")
                completion(.failure(NetworkError.genericError))
                return
               }
            completion(.success(jsonData, HTTPURLResponse(url: URL(string: mockAPI.validURL.path)!,
                                                          statusCode: 200,
                                                          httpVersion: nil,
                                                          headerFields: nil)!))
        } else if endpoint.path == "http://a-invalid-url.com" {
            let error = NSError(domain: "", code: 500)
            completion(.failure(error))
        }
        
    }
    
    
}
