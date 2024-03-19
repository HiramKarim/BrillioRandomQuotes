//
//  AuthorUseCase.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 27/12/23.
//

import Foundation

enum AuthorResult {
    case success(AuthorModel)
    case failure(Error)
}

protocol AuthorUseCaseProtocol {
    func fetchAuthorBio(from endpoint: EndPoint, completion: @escaping (AuthorResult) -> Void)
}

final class AuthorUseCase:AuthorUseCaseProtocol {
    
    var networkService: NetworkServiceProtocol!
    
    init(networkService:NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchAuthorBio(from endpoint: EndPoint,
                        completion: @escaping (AuthorResult) -> Void) {
        self.networkService.fetchData(from: endpoint) { result in
            switch result {
            case .success(let data, _):
                do {
                    let authorModel = try JSONDecoder().decode(AuthorModel.self, from: data)
                    completion(.success(authorModel))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
