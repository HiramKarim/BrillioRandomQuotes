//
//  AppCoorinator.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 26/12/23.
//

import UIKit

protocol CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
    func finish()
}

class AppCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol]
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.childCoordinators = []
        self.navigationController = navigationController
    }
    
    func start() {
        let quoteCoordinator = QuoteCoordinator(navigationController: navigationController,
                                                appCoordinator: self)
        quoteCoordinator.start()
        childCoordinators.append(quoteCoordinator)
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}

protocol QuoteCoordinatorProtocol {
    func goToAuthorDetails(authorSlug: String)
}

protocol QuoteNavCoordinator: CoordinatorProtocol, QuoteCoordinatorProtocol {}

class QuoteCoordinator: QuoteNavCoordinator {
    var childCoordinators: [CoordinatorProtocol]
    private var appCoordinator: CoordinatorProtocol?
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController,
         appCoordinator: CoordinatorProtocol?) {
        self.childCoordinators = []
        self.appCoordinator = appCoordinator
        self.navigationController = navigationController
    }
    
    func start() {
        guard let mainVC = buildAuthor()
        else { return }
        self.navigationController.pushViewController(mainVC, animated: true)
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
    
    func goToAuthorDetails(authorSlug:String = "") {
        guard let appCoordinator = appCoordinator else { return }
        let authorCoordinator = AuthorCoordinator(navigationController: navigationController,
                                                  appCoordinator: appCoordinator)
        authorCoordinator.loadParameters(authorSlug: authorSlug)
        authorCoordinator.start()
        childCoordinators.append(authorCoordinator)
    }
    
    internal func buildAuthor() -> MainVC? {
        let networkManager:NetworkServiceProtocol = Network()
        let useCase:QuotesUseCaseProtocol = QuotesUseCase(networkService: networkManager)
        let viewModel: QuoteVMProtocol = QuoteVM(useCase: useCase)
        return  MainVC(vm: viewModel, coordinator: self)
    }
}

protocol AutorNavCoordinator: CoordinatorProtocol {}

class AuthorCoordinator: AutorNavCoordinator {
    var childCoordinators: [any CoordinatorProtocol]
    private var appCoordinator: CoordinatorProtocol?
    var navigationController: UINavigationController
    var authorSlug:String = ""
    
    init(navigationController: UINavigationController,
         appCoordinator: CoordinatorProtocol?) {
        self.childCoordinators = []
        self.appCoordinator = appCoordinator
        self.navigationController = navigationController
    }
    
    func start() {
        guard let authorDetailsVC = createAuthor() else { return }
        self.navigationController.pushViewController(authorDetailsVC, animated: true)
    }
    
    func finish() {
        self.navigationController.popViewController(animated: true)
    }
}

extension AuthorCoordinator {
    func loadParameters(authorSlug:String) {
        self.authorSlug = authorSlug
    }
    
    private func createAuthor() -> AuthorDetailsVC? {
        let networkManager: NetworkServiceProtocol = Network()
        let useCase: AuthorUseCaseProtocol = AuthorUseCase(networkService: networkManager)
        let viewModel: AuthorVMProtocol = AuthorVM(authorUseCase: useCase, authorSlug: self.authorSlug)
        return AuthorDetailsVC(vm: viewModel, coordinator: self)
    }
}
