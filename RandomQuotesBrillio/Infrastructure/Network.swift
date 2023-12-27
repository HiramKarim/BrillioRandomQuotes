//
//  Network.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 26/12/23.
//

import Foundation

final class Network:NetworkServiceProtocol {
    
    func fetchData(from endpoint: EndPoint,
                   completion: @escaping (HTTPClientResult) -> Void) {
        
        guard let request = endpoint.request else { return }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.genericError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.genericError))
                return
            }
            
            switch response.statusCode {
            case 199...205:
                completion(.success(data, response))
                break
            default:
                completion(.failure(NetworkError.genericError))
                break
            }
            
        }.resume()
    }
    
}
