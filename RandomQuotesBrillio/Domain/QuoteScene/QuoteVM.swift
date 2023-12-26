//
//  QuoteVM.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 26/12/23.
//

import Foundation

protocol input {
    func fetchQuote()
}

protocol output {
    var fetchDataCallback:((String, String) -> Void)? { get set }
    var errorCallback:((Error) -> Void)? { get set }
}

protocol QuoteVMProtocol: input, output {}


class QuoteVM: QuoteVMProtocol {
    var fetchDataCallback: ((String, String) -> Void)?
    var errorCallback: ((Error) -> Void)?
    
    private let useCase:QuotesUseCaseProtocol?
    
    init(useCase: QuotesUseCaseProtocol) {
        self.useCase = useCase
    }
    
    func fetchQuote() {
        self.useCase?.fetchQuote(from: API.quotes, completion: { [weak self] result in
            var quoteString = ""
            var quoteAuthor = ""
            switch result {
            case .success(let quoteData):
                quoteString = quoteData.content ?? ""
                quoteAuthor = quoteData.author ?? ""
                self?.fetchDataCallback?(quoteString, quoteAuthor)
            case .failure(let error):
                self?.errorCallback?(error)
                break
            }
        })
    }
    
}
