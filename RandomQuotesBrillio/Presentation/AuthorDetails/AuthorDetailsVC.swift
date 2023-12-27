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
    
    let authorBioLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let linkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Link", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
    }
    
    private func configView() {
        self.view.backgroundColor = .white
        
        self.title = "Albert Einstein"
        
        self.view.addSubview(authorPicture)
        self.view.addSubview(authorBioLabel)
        self.view.addSubview(linkButton)
        
        NSLayoutConstraint.activate([
            authorPicture.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            authorPicture.safeAreaLayoutGuide.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,
                                                                   constant: 20),
            authorPicture.widthAnchor.constraint(equalToConstant: 100),
            authorPicture.heightAnchor.constraint(equalToConstant: 100),
            
            authorBioLabel.topAnchor.constraint(equalTo: authorPicture.bottomAnchor, constant: 30),
            authorBioLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            authorBioLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            
            linkButton.topAnchor.constraint(equalTo: authorBioLabel.bottomAnchor, constant: 10),
            linkButton.leadingAnchor.constraint(equalTo: authorBioLabel.leadingAnchor, constant: 0),
            linkButton.widthAnchor.constraint(equalToConstant: 30),
            linkButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        linkButton.layer.cornerRadius = 7
    }
    
}
