//
//  MainVC.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 26/12/23.
//

import UIKit

final class MainVC: UIViewController {
    
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
    
    let stackview: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 25
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    let quotesNumberTextfield: UITextField = {
        let textview = UITextField()
        textview.text = "1"
        textview.font = UIFont.systemFont(ofSize: 25)
        textview.textAlignment = .center
        textview.keyboardType = .numberPad
        textview.translatesAutoresizingMaskIntoConstraints = false
        
        return textview
    }()
    
    var vm:QuoteVMProtocol?
    var coordinator:AppCoordinator?
    
    deinit {
        vm?.fetchDataCallback = nil
        vm?.errorCallback = nil
        vm = nil
        coordinator = nil
    }
    
    init(vm: QuoteVMProtocol?,
         coordinator:AppCoordinator) {
        self.vm = vm
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configView()
        refreshQuote()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configView() {
        self.view.backgroundColor = .white
        
        self.view.addSubview(stackview)
        self.view.addSubview(loadingIndicator)
        
        stackview.addArrangedSubview(quoteLabel)
        stackview.addArrangedSubview(authorLabel)
        stackview.addArrangedSubview(refreshButton)
        stackview.addArrangedSubview(quotesNumberTextfield)
        
        NSLayoutConstraint.activate([
            stackview.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            stackview.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
            stackview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            stackview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            
            refreshButton.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.90),
            refreshButton.heightAnchor.constraint(equalToConstant: 50),
            
            quotesNumberTextfield.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.90),
            quotesNumberTextfield.heightAnchor.constraint(equalToConstant: 50),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        
        refreshButton.addTarget(self, action: #selector(refreshQuote), for: .touchUpInside)
        refreshButton.layer.cornerRadius = 7
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchAuthor))
        authorLabel.isUserInteractionEnabled = true
        authorLabel.addGestureRecognizer(tapGesture)
        
        quotesNumberTextfield.layer.borderColor = UIColor.gray.cgColor
        quotesNumberTextfield.layer.borderWidth = 1
        quotesNumberTextfield.layer.cornerRadius = 7
        quotesNumberTextfield.delegate = self
        
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc
    private func refreshQuote() {
        startLoadingIndicator()
        vm?.fetchQuote(completion: { [weak self] result in
            switch result {
            case .success(let quote):
                self?.loadQuote(quote: quote.content ?? "", author: quote.author ?? "")
            case .failure(let error):
                self?.showError(error: error)
            }
        })
    }
    
    private func loadQuote(quote:String, author: String) {
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
        self.coordinator?.goToAuthorDetails(authorSlug: vm?.getAuthorSlug() ?? "")
    }
    
}

extension MainVC {
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

extension MainVC : UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        switch textField {
        case quotesNumberTextfield:
            if ((textField.text?.count)! + (string.count - range.length)) > 2 {
                return false
            }

        case quotesNumberTextfield:
            if ((textField.text?.count)! + (string.count - range.length)) > 1 {
                return false
            }
        default:
            break
        }
        return true
    }
}

extension MainVC {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
