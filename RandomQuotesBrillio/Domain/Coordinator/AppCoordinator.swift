//
//  AppCoorinator.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 26/12/23.
//

import UIKit

protocol CoordinatorProtocol: AnyObject {
    var navigationController: UINavigationController { get set }
    
    func start()
}

protocol ChildCoordinatorsProtocol: AnyObject {
    var childCoordinators: [CoordinatorProtocol] { get set }
}

protocol CoordinatorFinishProtocol: AnyObject {
    func finish()
}

protocol MainCoordinatorProtocol: CoordinatorProtocol, 
                                    ChildCoordinatorsProtocol,
                                    CoordinatorFinishProtocol {}

class AppCoordinator: MainCoordinatorProtocol {
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

extension MainCoordinatorProtocol {
    func goToAuthorDetails(authorSlug:String = "") {
        let authorCoordinator = AuthorCoordinator(navigationController: navigationController, 
                                                  appCoordinator: self)
        authorCoordinator.loadParameters(authorSlug: authorSlug)
        authorCoordinator.start()
        childCoordinators.append(authorCoordinator)
    }
}

extension MainCoordinatorProtocol {
    func removeLast() {
        self.childCoordinators.removeLast()
    }
}

class QuoteCoordinator: CoordinatorProtocol {
    private weak var appCoordinator: MainCoordinatorProtocol?
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController,
         appCoordinator: MainCoordinatorProtocol?) {
        self.appCoordinator = appCoordinator
        self.navigationController = navigationController
    }
    
    func start() {
        let networkManager:NetworkServiceProtocol = Network()
        let useCase:QuotesUseCaseProtocol = QuotesUseCase(networkService: networkManager)
        let viewModel: QuoteVMProtocol = QuoteVM(useCase: useCase)
        
        guard let mainVC = buildAuthor()
        else { return }
        
        self.navigationController.pushViewController(mainVC, animated: true)
    }
}

extension QuoteCoordinator {
    private func buildAuthor() -> MainVC? {
        let networkManager:NetworkServiceProtocol = Network()
        let useCase:QuotesUseCaseProtocol = QuotesUseCase(networkService: networkManager)
        let viewModel: QuoteVMProtocol = QuoteVM(useCase: useCase)
        
        guard let appCoordinator = appCoordinator
        else { return nil }
        
        return  MainVC(vm: viewModel, coordinator: appCoordinator)
    }
}

class AuthorCoordinator: CoordinatorProtocol {
    private weak var appCoordinator: MainCoordinatorProtocol?
    var navigationController: UINavigationController
    
    var authorSlug:String = ""
    
    init(navigationController: UINavigationController,
         appCoordinator: MainCoordinatorProtocol?) {
        self.appCoordinator = appCoordinator
        self.navigationController = navigationController
    }
    
    func start() {
        guard let authorDetailsVC = createAuthor() else { return }
        self.navigationController.pushViewController(authorDetailsVC, animated: true)
    }
}

extension AuthorCoordinator {
    func loadParameters(authorSlug:String) {
        self.authorSlug = authorSlug
    }
}

extension AuthorCoordinator {
    private func createAuthor() -> AuthorDetailsVC? {
        let networkManager: NetworkServiceProtocol = Network()
        let useCase: AuthorUseCaseProtocol = AuthorUseCase(networkService: networkManager)
        let viewModel: AuthorVMProtocol = AuthorVM(authorUseCase: useCase, authorSlug: self.authorSlug)
        
        guard let appCoordinator = appCoordinator
        else { return nil }
        
        return AuthorDetailsVC(vm: viewModel, coordinator: appCoordinator)
    }
}

extension AuthorCoordinator: CoordinatorFinishProtocol {
    func finish() {
        self.navigationController.popViewController(animated: true)
    }
}
