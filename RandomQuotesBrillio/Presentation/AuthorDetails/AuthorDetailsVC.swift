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
    
    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    var vm:AuthorVMProtocol?
    var coordinator: AppCoordinator?
    
    deinit {
        self.vm = nil
    }
    
    init(vm:AuthorVMProtocol,
         coordinator: AppCoordinator) {
        self.vm = vm
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
        configCallbacks()
        fetchAuthorInformation()
    }
    
    private func configView() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(authorPicture)
        self.view.addSubview(authorBioLabel)
        self.view.addSubview(linkButton)
        self.view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            authorPicture.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            authorPicture.safeAreaLayoutGuide.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,
                                                                   constant: 20),
            authorPicture.widthAnchor.constraint(equalToConstant: 100),
            authorPicture.heightAnchor.constraint(equalToConstant: 100),
            
            authorBioLabel.topAnchor.constraint(equalTo: authorPicture.bottomAnchor, constant: 30),
            authorBioLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            authorBioLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            
            linkButton.topAnchor.constraint(equalTo: authorBioLabel.bottomAnchor, constant: 50),
            linkButton.trailingAnchor.constraint(equalTo: authorBioLabel.trailingAnchor, constant: -10),
            linkButton.widthAnchor.constraint(equalToConstant: 100),
            linkButton.heightAnchor.constraint(equalToConstant: 30),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0)
        ])
        
        linkButton.addTarget(self, action: #selector(openLink), for: .touchUpInside)
        linkButton.layer.cornerRadius = 7
    }
    
    private func configCallbacks() {
        vm?.fetchDataCallback = loadAuthorInformation
        vm?.errorCallback = showError
    }
    
    private func fetchAuthorInformation() {
        startLoadingIndicator()
        vm?.fetchAuthorBio(completion: { [weak self] result in
            switch result {
            case .success(let authorData):
                self?.loadAuthorInformation(authorModel: authorData)
            case .failure(let error):
                self?.showError(error: error)
            }
        })
    }
    
    private func loadAuthorInformation(authorModel:AuthorModel) {
        stopLoadingIndicator()
        DispatchQueue.main.async {
            self.title = authorModel.name ?? ""
            self.authorBioLabel.text = authorModel.bio ?? ""
        }
    }
    
    private func showError(error: Error) {
        stopLoadingIndicator()
    }
    
    @objc
    private func openLink() {
        if let url = URL(string: vm?.getBioLink() ?? ""),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
}

extension AuthorDetailsVC {
    private func startLoadingIndicator() {
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
    }
    
    private func stopLoadingIndicator() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
        }
    }
}
