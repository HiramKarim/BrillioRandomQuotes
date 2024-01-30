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
    
    func test_deliversValidAuthorBioForValidURL() {
        let networkServiceMock = NetworkServiceMock()
        let usecase = AuthorUseCase(networkService: networkServiceMock)
        let sut = AuthorVM(authorUseCase: usecase, authorSlug: "charles-dickens")
        
        let exp = expectation(description: "waiting for response")
        
        sut.fetchAuthorBio { result in
            switch result {
            case .success(let author):
                XCTAssertNotNil(author)
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
        
        if endpoint.path == "http://a-valid-quote-url.com" ||
            endpoint.path.contains("https://api.quotable.io/quotes/random?limit="){
            
            let jsonString = """
            [{
                "_id":"yW0uii1d-O",
                "author":"Woody Allen",
                "content":"Interestingly, according to modern astronomers, space is finite. This is a very comforting thought-- particularly for people who can never remember where they have left things.",
                "tags":["Film"],
                "authorSlug":"woody-allen",
                "length":176,
                "dateAdded":"2019-03-17",
                "dateModified":"2023-04-14"
            }]
            """
            
            let jsonData = Data(jsonString.utf8)
            
            completion(.success(jsonData, HTTPURLResponse(url: URL(string: mockAPI.quoteURL.path)!,
                                                          statusCode: 200,
                                                          httpVersion: nil,
                                                          headerFields: nil)!))
        } else if endpoint.path.contains("https://api.quotable.io/authors/slug/") {
            let jsonString = """
            {
                "_id":"yW0uii1d-O",
                "name":"Woody Allen",
                "link":"www.a-link.com",
                "bio":"some bio...",
                "slug":"woody-allen"
            }
            """
            
            let jsonData = Data(jsonString.utf8)
            
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
