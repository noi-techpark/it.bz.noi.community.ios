//
//  BaseRootCoordinator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 28/04/22.
//

import UIKit

class BaseRootCoordinator: BaseCoordinator, RootCoordinatorType {

    var window: UIWindow
    
    @available(*, unavailable)
    override init(dependencyContainer: DependencyRepresentable) {
        fatalError("\(#function) not available")
    }
    
    init(
        window: UIWindow,
        dependencyContainer: DependencyRepresentable
    ) {
        self.window = window
        super.init(dependencyContainer: dependencyContainer)
    }
    
    override func start(animated: Bool) {
        guard type(of: self) != BaseRootCoordinator.self
        else { preconditionFailure("subclass should implement start function!") }
    }

}
