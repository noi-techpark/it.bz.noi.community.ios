//
//  LoadAppPreferencesMainViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 18/11/21.
//

import Combine
import UIKit
import AppPreferencesClient

// MARK: - LoadAppPreferencesMainViewController

class LoadAppPreferencesMainViewController: UIViewController {
    private var subscriptions: Set<AnyCancellable> = []

    let viewModel: LoadAppPreferencesViewModel
    let didLoadHandler: (AppPreferences) -> Void

    init(
        viewModel: LoadAppPreferencesViewModel,
        didLoadHandler: @escaping (AppPreferences) -> Void
    ) {
        self.viewModel = viewModel
        self.didLoadHandler = didLoadHandler
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    @available(*, unavailable)
    override init(
        nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: Bundle?
    ) {
        fatalError("\(#function) not implemented")
    }

    override func loadView() {
        super.loadView()
        view.backgroundColor = .noiBackgroundColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureBindings()
        viewModel.load()
    }
}

// MARK: Private APIs

private extension LoadAppPreferencesMainViewController {
    func updateContent(isLoading: Bool) {
        if isLoading {
            embedChild(LoadingViewController(style: .dark), in: view)
        } else {
            children.forEach { child in
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
        }
    }

    func configureBindings() {
        viewModel.$isLoading
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                guard let self = self
                else { return }

                self.updateContent(isLoading: isLoading)
            })
            .store(in: &subscriptions)

        viewModel.$appPreferences
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] appPreferences in
                if let appPreferences = appPreferences {
                    self?.didLoadHandler(appPreferences)
                }
            }
            .store(in: &subscriptions)
    }
}
