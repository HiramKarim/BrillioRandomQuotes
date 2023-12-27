//
//  MainVC.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 26/12/23.
//

import UIKit

class MainVC: UIViewController {
    
    let quoteLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let authorLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Refresh", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let authorDetailButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    var vm:QuoteVMProtocol?
    
    deinit {
        vm?.fetchDataCallback = nil
        vm?.errorCallback = nil
        vm = nil
    }
    
    init(vm: QuoteVMProtocol?) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
        configCallbacks()
        refreshQuote()
    }
    
    private func configView() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(quoteLabel)
        self.view.addSubview(authorLabel)
        self.view.addSubview(refreshButton)
        self.view.addSubview(authorDetailButton)
        self.view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            quoteLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            quoteLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 20),
            quoteLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            quoteLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            
            authorLabel.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 30),
            authorLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),

            refreshButton.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 30),
            refreshButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            refreshButton.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.90),
            refreshButton.heightAnchor.constraint(equalToConstant: 50),
            
            authorDetailButton.topAnchor.constraint(equalTo: authorLabel.topAnchor),
            authorDetailButton.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            authorDetailButton.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor),
            authorDetailButton.bottomAnchor.constraint(equalTo: authorLabel.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0)
        ])
        
        refreshButton.addTarget(self, action: #selector(refreshQuote), for: .touchUpInside)
        refreshButton.layer.cornerRadius = 7
        
        authorDetailButton.addTarget(self, action: #selector(searchAuthor), for: .touchUpInside)
    }
    
    func configCallbacks() {
        vm?.fetchDataCallback = reloadQuotes
        vm?.errorCallback = showError
    }
    
    @objc
    private func refreshQuote() {
        startLoadingIndicator()
        vm?.fetchQuote()
    }
    
    private func reloadQuotes(quote:String, author: String) {
        DispatchQueue.main.async {
            self.quoteLabel.text = quote
            self.authorLabel.text = author
        }
        stopLoadingIndicator()
    }
    
    private func showError(error:Error) {
        stopLoadingIndicator()
        let alert = UIAlertController(title: "Alert",
                                      message: "An error occur, pleace try again.",
                                      preferredStyle: .alert)
        let confirmButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(confirmButton)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    @objc
    private func searchAuthor() {
        //TODO: Move to show author details
    }
    
}

extension MainVC {
    func startLoadingIndicator() {
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
    }
    
    func stopLoadingIndicator() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
        }
    }
}
