//
//  MessageViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 24/09/21.
//

import UIKit

struct Message {
    struct Action {
        let title: String
        let handler: () -> Void
    }

    let text: String
    let detailedText: String?
    let image: UIImage?
    let action: Action?

    init(
        text: String,
        detailedText: String? = nil,
        image: UIImage? = nil,
        action: Action? = nil
    ) {
        self.text = text
        self.detailedText = detailedText
        self.image = image
        self.action = action
    }

    init(
        text: String,
        detailedText: String? = nil,
        image: UIImage? = nil,
        actionTitle: String,
        actionHandler: @escaping () -> Void
    ) {
        self.text = text
        self.detailedText = detailedText
        self.image = image
        self.action = Action(title: actionTitle, handler: actionHandler)
    }
}

final class MessageViewController: UIViewController {

    var refreshControl: UIRefreshControl? {
        didSet {
            scrollView?.refreshControl = refreshControl
        }
    }
    
    private let message: Message

    @IBOutlet private var scrollView: UIScrollView?
    @IBOutlet private var imageView: UIImageView?
    @IBOutlet private var textLabel: UILabel? {
        didSet {
            guard let textLabel = textLabel
            else { return }

            textLabel.font = .preferredFont(forTextStyle: .body, weight: .bold)
        }
    }
    @IBOutlet private var detailedTextLabel: UILabel?
    @IBOutlet private var actionButton: UIButton?

    init(message: Message) {
        self.message = message
        super.init(nibName: "\(MessageViewController.self)", bundle: nil)
    }

    convenience init(
        text: String,
        detailedText: String? = nil,
        image: UIImage? = nil,
        action: Message.Action? = nil
    ) {
        self.init(message: .init(
            text: text,
            detailedText: detailedText,
            image: image, action: action
        ))
    }

    convenience init(
        text: String,
        detailedText: String? = nil,
        image: UIImage? = nil,
        actionTitle: String,
        actionHandler: @escaping () -> Void
    ) {
        self.init(message: .init(
            text: text,
            detailedText: detailedText,
            image: image,
            actionTitle: actionTitle,
            actionHandler: actionHandler))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView?.refreshControl = refreshControl
        if let image = message.image {
            imageView?.image = image
        } else {
            imageView?.removeFromSuperview()
        }

        textLabel?.text = message.text

        if let detailedText = message.detailedText {
            detailedTextLabel?.text = detailedText
        } else {
            detailedTextLabel?.removeFromSuperview()
        }

        if let action = message.action {
            actionButton?.setTitle(action.title, for: .normal)
        } else {
            actionButton?.removeFromSuperview()
        }

    }

    @IBAction private func performAction(_ sender: UIButton) {
        message.action?.handler()
    }
}
