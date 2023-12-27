//
//  AuthorDetailsVC.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 27/12/23.
//

import UIKit

final class AuthorDetailsVC: UIViewController {
    
    let authorPicture: UIImageView = {
        let picture = UIImageView()
        picture.translatesAutoresizingMaskIntoConstraints = false
        return picture
    }()
    
    let authorDescriptionLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
