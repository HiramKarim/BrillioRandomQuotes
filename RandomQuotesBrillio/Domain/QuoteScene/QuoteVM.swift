//
//  QuoteVM.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 26/12/23.
//

import Foundation

protocol input {
    func fetchQuote(completion: @escaping (QuoteResult) -> Void)
}

protocol output {
    var fetchDataCallback:((String, String) -> Void)? { get set }
    var errorCallback:((Error) -> Void)? { get set }
    func getAuthorSlug() -> String
}

protocol QuoteVMProtocol: input, output { }

final class QuoteVM: QuoteVMProtocol {
    var fetchDataCallback: ((String, String) -> Void)?
    var errorCallback: ((Error) -> Void)?
    
    private let useCase:QuotesUseCaseProtocol?
    private var authorSlug = ""
    
    init(useCase: QuotesUseCaseProtocol) {
        self.useCase = useCase
    }
    
    func fetchQuote(completion: @escaping (QuoteResult) -> Void) {
        self.useCase?.fetchQuote(from: API.quotes, completion: { [weak self] result in
            switch result {
            case .success(let quoteData):
                self?.authorSlug = quoteData.authorSlug ?? ""
                completion(.success(quoteData))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func getAuthorSlug() -> String {
        return self.authorSlug
    }
    
}
