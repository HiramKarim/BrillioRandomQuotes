//
//  AuthorModel.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 27/12/23.
//

import Foundation

struct AuthorModel:Decodable {
    let id:String?
    let name:String?
    let link:String?
    let bio:String?
    let description:String?
    let slug:String?
    
    enum CondigKeys: String, CodingKey {
        case id = "_id"
        case name = "name"
        case link = "link"
        case bio = "bio"
        case description = "description"
        case slug = "slug"
    }
}
