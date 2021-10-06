//
//  EventDetailsViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/09/21.
//

import UIKit
import Kingfisher

class EventDetailsViewController: UIViewController {
    
    let event: Event
    let relatedEvents: [Event]
    
    var locateActionHandler: ((Event) -> Void)?
    var addToCalendarActionHandler: ((Event) -> Void)?
    var didSelectRelatedEventHandler: ((
        UICollectionView,
        UICollectionViewCell,
        IndexPath,
        Event
    ) -> Void)?

    private var _cardView: (UIView & UIContentView)!

    var cardView: (UIView & UIContentView)! {
        loadViewIfNeeded()
        return _cardView
    }
    
    private var relatedEventsVC: EventListViewController!
    
    @IBOutlet private var scrollView: UIScrollView! {
        didSet {
            scrollView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 30,
                right: 0
            )
        }
    }
    
    @IBOutlet private var contentStackView: UIStackView!
    
    @IBOutlet private var aboutSection: UIView! {
        didSet {
            if event.description.isNilOrEmpty {
                aboutSection.removeFromSuperview()
            }
        }
    }
    
    @IBOutlet private var aboutLabel: UILabel! {
        didSet {
            aboutLabel.text = .localized("label_about")
        }
    }
    
    @IBOutlet private var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.text = event.description
        }
    }
    
    @IBOutlet private var relatedSection: UIView! {
        didSet {
            if relatedEvents.isEmpty {
                relatedSection.removeFromSuperview()
            }
        }
    }
    
    @IBOutlet private var relatedEventsLabel: UILabel! {
        didSet {
            relatedEventsLabel.text = .localized("label_interesting_for_you")
        }
    }
    
    @IBOutlet private var relatedEventsContainerView: UIView!
    
    @IBOutlet private var relatedEventsContainerViewHeight: NSLayoutConstraint!
    
    @IBOutlet private var actionsContainersView: UIView! {
        didSet {
            actionsContainersView.layer.shadowPath = UIBezierPath(rect: actionsContainersView.bounds).cgPath
            actionsContainersView.layer.shadowColor = UIColor.backgroundColor.cgColor
            actionsContainersView.layer.shadowRadius = 5
            actionsContainersView.layer.shadowOffset = .zero
            actionsContainersView.layer.shadowOpacity = 0.16
        }
    }
    
    @IBOutlet private var locateEventButton: UIButton! {
        didSet {
            locateEventButton.setTitle(
                .localized("btn_find_on_maps"),
                for: .normal
            )
        }
    }
    
    @IBOutlet private var addToCalendarButton: UIButton! {
        didSet {
            addToCalendarButton.setTitle(
                .localized("btn_add_to_calendar"),
                for: .normal
            )
        }
    }
    
    init(for item: Event, relatedEvents: [Event]) {
        self.event = item
        self.relatedEvents = relatedEvents
        super.init(nibName: "\(EventDetailsViewController.self)", bundle: nil)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewHierarchy()
        configureChilds()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        actionsContainersView.layer.shadowPath = UIBezierPath(rect: actionsContainersView.bounds).cgPath
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        
        if container === relatedEventsVC {
            relatedEventsContainerViewHeight.constant = container.preferredContentSize.height
        }
    }
}

// MARK: Private APIs
private extension EventDetailsViewController {
    func configureViewHierarchy() {
        var contentConfiguration = EventCardContentConfiguration.makeDetailedContentConfiguration(for: event)
        defer {
            _cardView = contentConfiguration.makeContentView()
            contentStackView.insertArrangedSubview(_cardView, at: 0)
        }
        
        if let imageURL = event.imageURL {
            KingfisherManager.shared.retrieveImage(with: imageURL) { [weak _cardView] result in
                guard case let .success(imageInfo) = result
                else { return }
                
                contentConfiguration.image = imageInfo.image
                _cardView?.configuration = contentConfiguration
            }
        }
    }
    
    func configureChilds() {
        guard !relatedEvents.isEmpty
        else { return }
        
        relatedEventsVC = EventListViewController(
            items: relatedEvents,
            embeddedHorizontally: true
        )
        relatedEventsVC.didSelectHandler = { [weak self] in
            self?.didSelectRelatedEventHandler?($0, $1, $2, $3)
        }
        embedChild(relatedEventsVC, in: relatedEventsContainerView)
        relatedEventsContainerViewHeight.constant = relatedEventsVC.preferredContentSize.height
    }
    
    @IBAction func findOnMapsAction(sender: Any?) {
        locateActionHandler?(event)
    }
    
    @IBAction func addToCalendarAction(sender: Any?) {
        addToCalendarActionHandler?(event)
    }
}

extension EventDetailsViewController: CurrentScrollOffsetProvider
{
    var currentScrollOffset: CGPoint {
        relatedEventsVC?.currentScrollOffset ?? .zero
    }
}
