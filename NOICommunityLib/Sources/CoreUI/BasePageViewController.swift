// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  BasePageViewController.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 03/12/24.
//

import UIKit
import Combine

// MARK: - BasePageViewController

open class BasePageViewController<VM: BasePageViewModel, DC>: UIViewController {

	public let viewModel: VM
	public let dependencyContainer: DC
	public var subscriptions: Set<AnyCancellable> = []

	@available(*, unavailable)
	required public init?(coder: NSCoder) {
		fatalError("\(#function) not available")
	}

	@available(*, unavailable)
	public override init(
		nibName nibNameOrNil: String?,
		bundle nibBundleOrNil: Bundle?
	) {
		fatalError("\(#function) not available")
	}

	public init(viewModel: VM, dependencyContainer: DC) {
		self.viewModel = viewModel
		self.dependencyContainer = dependencyContainer

		super.init(nibName: nil, bundle: nil)

		configureBindings()
	}

	open func configureBindings() {}

	open func configureLayout() {}

	open override func viewDidLoad() {
		super.viewDidLoad()

		viewModel.onViewDidLoad()
		configureLayout()
	}

	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		viewModel.onViewWillAppear(animated)
	}

	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		viewModel.onViewDidAppear(animated)
	}

	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		viewModel.onViewWillDisappear(animated)
	}

	open override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		viewModel.onViewDidDisappear(animated)
	}

}
