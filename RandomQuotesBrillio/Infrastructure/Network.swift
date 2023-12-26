//
//  Network.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 26/12/23.
//

import Foundation

final class Network:NetworkServiceProtocol {
    
    func fetchQuote(from endpoint: EndPoint, completion: @escaping (HTTPClientResult) -> Void) {
        
        URLSession.shared.dataTask(with: URL(string: endpoint.path)!) { data, response, error in
            
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
