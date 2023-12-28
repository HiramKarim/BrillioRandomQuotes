//
//  QuoteVM.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 26/12/23.
//

import Foundation

protocol input {
    func fetchQuote(limit:Int, completion: @escaping (QuoteResult) -> Void)
}

protocol output {
    var fetchDataCallback:((String, String) -> Void)? { get set }
    var errorCallback:((Error) -> Void)? { get set }
    func getAuthorSlug(index:Int) -> String
    func getQuotesList() -> [QuoteModel]
    func getQuotesListCount() -> Int
    func getQuote(index: Int) -> QuoteModel
}

protocol QuoteVMProtocol: input, output { }

final class QuoteVM: QuoteVMProtocol {
    var fetchDataCallback: ((String, String) -> Void)?
    var errorCallback: ((Error) -> Void)?
    
    private let useCase:QuotesUseCaseProtocol?
    private var quotesList = [QuoteModel]()
    
    init(useCase: QuotesUseCaseProtocol) {
        self.useCase = useCase
    }
    
    func fetchQuote(limit:Int = 0, completion: @escaping (QuoteResult) -> Void) {
        self.useCase?.fetchQuote(from: API.quotesList(limit: limit), completion: { [weak self] result in
            switch result {
            case .success(let quoteData):
                self?.quotesList = quoteData
                completion(.success(quoteData))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func getAuthorSlug(index:Int = 0) -> String {
        return quotesList[index].authorSlug ?? ""
    }
    
    func getQuotesList() -> [QuoteModel] {
        return quotesList
    }
    
    func getQuotesListCount() -> Int {
        return quotesList.count
    }
    
    func getQuote(index: Int) -> QuoteModel {
        return quotesList[index]
    }
    
}
