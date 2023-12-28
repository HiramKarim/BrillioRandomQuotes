//
//  MainVC.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 26/12/23.
//

import UIKit

final class MainVC: UIViewController {
    
    private let cellIdentifier = "cell"
    
    private let tableview: UITableView = {
        let tableview = UITableView(frame: .zero)
        tableview.rowHeight = 80
        tableview.estimatedRowHeight = 80
        tableview.translatesAutoresizingMaskIntoConstraints = false
        return tableview
    }()
    
    private let quoteLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Refresh", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let authorDetailButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let stackview: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.vertical
        stackView.distribution = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing = 25
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private let quotesNumberTextfield: UITextField = {
        let textview = UITextField()
        textview.text = "1"
        textview.font = UIFont.systemFont(ofSize: 25)
        textview.textAlignment = .center
        textview.keyboardType = .numberPad
        textview.translatesAutoresizingMaskIntoConstraints = false
        
        return textview
    }()
    
    private var vm:QuoteVMProtocol?
    private var coordinator:AppCoordinator?
    
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
        
        self.view.addSubview(tableview)
        self.view.addSubview(refreshButton)
        self.view.addSubview(quotesNumberTextfield)
        
        NSLayoutConstraint.activate([
            stackview.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            stackview.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
            stackview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            stackview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            
            tableview.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            tableview.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
            tableview.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.90),
            tableview.heightAnchor.constraint(equalToConstant: 150),
            
            refreshButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            refreshButton.topAnchor.constraint(equalTo: stackview.bottomAnchor, constant: 25),
            refreshButton.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.90),
            refreshButton.heightAnchor.constraint(equalToConstant: 50),
            
            quotesNumberTextfield.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            quotesNumberTextfield.topAnchor.constraint(equalTo: refreshButton.bottomAnchor, constant: 25),
            quotesNumberTextfield.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.90),
            quotesNumberTextfield.heightAnchor.constraint(equalToConstant: 50),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        
        refreshButton.addTarget(self, action: #selector(refreshQuote), for: .touchUpInside)
        refreshButton.layer.cornerRadius = 7
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showAuthorDetail))
        authorLabel.isUserInteractionEnabled = true
        authorLabel.addGestureRecognizer(tapGesture)
        
        quotesNumberTextfield.layer.borderColor = UIColor.gray.cgColor
        quotesNumberTextfield.layer.borderWidth = 1
        quotesNumberTextfield.layer.cornerRadius = 7
        quotesNumberTextfield.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableview.isHidden = true
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    @objc
    private func refreshQuote() {
        dismissKeyboard()
        startLoadingIndicator()
        
        if getLimitAmount() == 0 || getLimitAmount() > 50 {
            stopLoadingIndicator()
            showAlertMessage(message: "The min limit quote is 1 and the max is 50.")
        } else {
            vm?.fetchQuote(limit: getLimitAmount(), completion: { [weak self] result in
                switch result {
                case .success(let quote):
                    self?.loadQuote(quoteData: quote)
                case .failure(let error):
                    self?.showError(error: error)
                }
            })
        }
    }
    
    private func loadQuote(quoteData:[QuoteModel]) {
        stopLoadingIndicator()
        if quoteData.count > 1 {
            DispatchQueue.main.async {
                self.stackview.isHidden = true
                self.tableview.isHidden = false
                self.tableview.reloadData()
            }
            
        } else {
            let quote = quoteData.first!
            DispatchQueue.main.async {
                self.stackview.isHidden = false
                self.tableview.isHidden = true
                self.quoteLabel.text = quote.content ?? ""
                self.authorLabel.text = quote.author ?? ""
            }
        }
    }
    
    private func showError(error:Error) {
        stopLoadingIndicator()
        showAlertMessage(message: "An unexpected error has occurred. Please try again")
    }
    
    @objc
    private func showAuthorDetail() {
        searchAuthor()
    }
    
    
    private func searchAuthor(at index:Int = 0) {
        self.coordinator?.goToAuthorDetails(authorSlug: vm?.getAuthorSlug(index: index) ?? "")
    }
    
    private func getLimitAmount() -> Int {
        return Int(quotesNumberTextfield.text ?? "1") ?? 1
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

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

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
        view.endEditing(true)
    }
}

extension MainVC {
    private func showAlertMessage(message:String) {
        let alert = UIAlertController(title: "Alert",
                                      message: message,
                                      preferredStyle: .alert)
        let confirmButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(confirmButton)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

extension MainVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm?.getQuotesListCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let quote = vm?.getQuote(index: indexPath.row)
        cell.textLabel?.text = "\(quote?.content ?? "") - \(quote?.author ?? "")"
        
        return cell
    }
}

extension MainVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchAuthor(at: indexPath.row)
    }
}
