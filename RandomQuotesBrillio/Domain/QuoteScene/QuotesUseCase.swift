//
//  QuotesUseCase.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 26/12/23.
//

import Foundation

enum QuoteResult {
    case success(QuoteModel)
    case failure(Error)
}

protocol QuotesUseCaseProtocol {
    func fetchQuote(from endpoint: EndPoint, completion: @escaping (QuoteResult) -> Void)
}

final class QuotesUseCase: QuotesUseCaseProtocol {
    
    private var networkService: NetworkServiceProtocol!
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchQuote(from endpoint: EndPoint, completion: @escaping (QuoteResult) -> Void) {
        self.networkService.fetchData(from: endpoint) { result in
            switch result {
            case .success(let data, _):
                do {
                    let quoteData = try JSONDecoder().decode(QuoteModel.self, from: data)
                    completion(.success(quoteData))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
}
