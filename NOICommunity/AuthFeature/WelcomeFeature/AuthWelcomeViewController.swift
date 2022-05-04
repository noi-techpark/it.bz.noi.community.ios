//
//  AuthWelcomeViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 13/04/22.
//

import UIKit
import Combine

// MARK: - AuthWelcomeViewController

final class AuthWelcomeViewController: UIViewController {
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private var viewModel: WelcomeViewModel
    
    private var pageToPageViewController: [Int: AuthWelcomePageViewController] = [:]
    
    @IBOutlet var pagesContainerView: UIView!
    
    @IBOutlet var footerView: UIView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var loginButton: UIButton! {
        didSet {
            loginButton
                .withText(.localized("btn_login"))
                .withDynamicType()
                .withTextStyle(.title3, weight: .semibold)
                .withTextAligment(.center)
        }
    }
    
    @IBOutlet var signUpButton: UIButton! {
        didSet {
            signUpButton
                .withText(.localized("btn_signup"))
                .withDynamicType()
                .withTextStyle(.title3, weight: .semibold)
                .withTextAligment(.center)
        }
    }
    
    private lazy var pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )
    
    init(viewModel: WelcomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "\(AuthWelcomeViewController.self)", bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBindings()
        
        pageControl.numberOfPages = viewModel.pages.count
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        embedChild(pageViewController, in: pagesContainerView)
        
        let firstPageVC = makePageContentViewController(for: 0)
        pageToPageViewController[0] = firstPageVC
        pageViewController.setViewControllers(
            [firstPageVC],
            direction: .forward,
            animated: false
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pageToPageViewController.forEach { (_, pageVC) in
            pageVC.topMargin = view.convert(
                self.footerView.frame.origin,
                to: pageVC.view
            ).y - 18
        }
    }
    
}

// MARK: Private APIs

private extension AuthWelcomeViewController {
    
    func configureBindings() {
        loginButton
            .publisher(for: .primaryActionTriggered)
                .sink { [weak viewModel] in
                    viewModel?.startLogin()
                }
                .store(in: &subscriptions)
        
        signUpButton
            .publisher(for: .primaryActionTriggered)
                .sink { [weak viewModel] in
                    viewModel?.startSignUp()
                }
                .store(in: &subscriptions)
    }
    
    func knownPagePosition(of viewController: UIViewController) -> Int? {
        pageToPageViewController.first { $0.value === viewController }?.key
    }
    
    func pageContentViewController(
        from referenceViewController: UIViewController,
        requiringPageIndex: (Int) -> Int
    ) -> UIViewController? {
        let pageIndex = knownPagePosition(of: referenceViewController)!
        let requiredPageIndex = requiringPageIndex(pageIndex)
        
        guard viewModel.pages.indices.contains(requiredPageIndex)
        else { return nil }
        
        let pageVC: AuthWelcomePageViewController
        
        if let availablePageVC = pageToPageViewController[requiredPageIndex] {
            pageVC = availablePageVC
        } else {
            pageVC = makePageContentViewController(for: requiredPageIndex)
            pageToPageViewController[requiredPageIndex] = pageVC
        }
        
        return pageVC
    }
    
    func makePageContentViewController(
        for page: Int
    ) -> AuthWelcomePageViewController {
        let pageVC = AuthWelcomePageViewController(
            nibName: "\(AuthWelcomePageViewController.self)",
            bundle: nil
        )
        pageVC.configure(with: viewModel.pages[page])
        pageVC.topMargin = view.convert(
            self.footerView.frame.origin,
            to: pageVC.view
        ).y - 18
        return pageVC
    }
    
}

// MARK: UIPageViewControllerDataSource

extension AuthWelcomeViewController: UIPageViewControllerDataSource {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        pageContentViewController(from: viewController) { $0 - 1 }
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        pageContentViewController(from: viewController) { $0 + 1 }
    }
    
}

// MARK: UIPageViewControllerDelegate

extension AuthWelcomeViewController: UIPageViewControllerDelegate {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
            let pageContentVC = pageViewController.viewControllers?.first
            let currentPage = knownPagePosition(of: pageContentVC!)!
            pageControl.currentPage = currentPage
        }
    
}

// MARK: AuthWelcomePageViewController+Configuration

private extension AuthWelcomePageViewController {
    
    func configure(with page: WelcomePage) {
        loadViewIfNeeded()
        backgroundImageView.kf.setImage(with: page.backgroundImageURL)
        textLabel.text = page.title
        detailedTextLabel.text = page.description
    }
    
}
