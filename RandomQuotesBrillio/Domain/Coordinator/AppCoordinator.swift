//
//  AppCoorinator.swift
//  RandomQuotesBrillio
//
//  Created by Hiram Castro on 26/12/23.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

class QuoteCoordinator: Coordinator {
    var childCoordinators: [Coordinator]
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.childCoordinators = []
        self.navigationController = navigationController
    }
    
    func start() {
        let networkManager:NetworkServiceProtocol = Network()
        let useCase:QuotesUseCaseProtocol = QuotesUseCase(networkService: networkManager)
        let viewModel: QuoteVMProtocol = QuoteVM(useCase: useCase)
        let mainVC = MainVC(vm: viewModel, coordinator: childCoordinators.first! as! AppCoordinator)
        
        self.navigationController.pushViewController(mainVC, animated: true)
    }
}

class AuthorCoordinator: Coordinator {
    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController
    
    var authorSlug:String = ""
    
    init(navigationController: UINavigationController) {
        self.childCoordinators = []
        self.navigationController = navigationController
    }
    
    func start() {
        let networkManager: NetworkServiceProtocol = Network()
        let useCase: AuthorUseCaseProtocol = AuthorUseCase(networkService: networkManager)
        let viewModel: AuthorVMProtocol = AuthorVM(authorUseCase: useCase, authorSlug: self.authorSlug)
        let authorDetails = AuthorDetailsVC(vm: viewModel)
        self.navigationController.pushViewController(authorDetails, animated: true)
    }
}

extension AuthorCoordinator {
    func loadParameters(authorSlug:String) {
        self.authorSlug = authorSlug
    }
}


class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator]
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.childCoordinators = []
        self.navigationController = navigationController
    }
    
    func start() {
        let quoteCoordinator = QuoteCoordinator(navigationController: navigationController)
        quoteCoordinator.childCoordinators.append(self)
        quoteCoordinator.start()
        childCoordinators.append(quoteCoordinator)
    }
}

extension AppCoordinator {
    func goToAuthorDetails(authorSlug:String = "") {
        let authorCoordinator = AuthorCoordinator(navigationController: navigationController)
        authorCoordinator.loadParameters(authorSlug: authorSlug)
        authorCoordinator.start()
        childCoordinators.append(authorCoordinator)
    }
}
