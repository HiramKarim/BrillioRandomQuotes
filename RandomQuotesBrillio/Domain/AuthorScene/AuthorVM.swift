//
//  AuthorVM.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 27/12/23.
//

import Foundation

protocol AuthorInput {
    func fetchAuthorBio(completion: @escaping (AuthorResult) -> Void)
    var authorSlug:String { get set }
}

protocol AuthorOutput {
    var fetchDataCallback:((AuthorModel) -> Void)? { get set }
    var errorCallback:((Error) -> Void)? { get set }
    func getBioLink() -> String
}

protocol AuthorVMProtocol: AuthorInput, AuthorOutput { }

final class AuthorVM: AuthorVMProtocol {
    var authorUseCase:AuthorUseCaseProtocol?
    
    var fetchDataCallback: ((AuthorModel) -> Void)?
    var errorCallback: ((Error) -> Void)?
    
    internal var authorSlug:String = ""
    internal var bioLink:String = ""
    
    init(authorUseCase:AuthorUseCaseProtocol,
         authorSlug:String) {
        self.authorUseCase = authorUseCase
        self.authorSlug = authorSlug
    }
    
    func fetchAuthorBio(completion: @escaping (AuthorResult) -> Void) {
        self.authorUseCase?.fetchAuthorBio(from: API.author(slug: authorSlug), completion: { [weak self] result in
            switch result {
            case .success(let authorData):
                self?.bioLink = authorData.link ?? ""
                completion(.success(authorData))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func getBioLink() -> String {
        return self.bioLink
    }
}
