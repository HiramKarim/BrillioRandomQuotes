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
        let mainVC = MainVC(vm: viewModel)
        
        self.navigationController.pushViewController(mainVC, animated: true)
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
        quoteCoordinator.start()
        childCoordinators.append(quoteCoordinator)
    }
    
    
}
