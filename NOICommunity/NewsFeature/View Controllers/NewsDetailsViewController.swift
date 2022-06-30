//
//  NewsDetailViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/05/22.
//

import UIKit
import Combine
import ArticlesClient

class NewsDetailsViewController: UIViewController {
    
    let newsId: String
    
    let viewModel: NewsDetailsViewModel
    
    var externalLinkActionHandler: ((Article, Any?) -> Void)?
    
    var askQuestionActionHandler: ((Article, Any?) -> Void)?
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private lazy var refreshControl: UIRefreshControl = { refreshControl in
        scrollView.refreshControl = refreshControl
        return refreshControl
    }(UIRefreshControl())
    
    @IBOutlet private var scrollView: UIScrollView!
    
    @IBOutlet private var containerView: UIView!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var authorLabel: UILabel! {
        didSet {
            authorLabel.font = .NOI.dynamic.footnoteSemibold
        }
    }
    
    @IBOutlet private var publishedDateLabel: UILabel! {
        didSet {
            publishedDateLabel.font = .NOI.dynamic.bodyRegular
        }
    }
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.font = .NOI.dynamic.footnoteSemibold
        }
    }
    
    @IBOutlet private var abstractLabel: UILabel! {
        didSet {
            abstractLabel.font = .NOI.dynamic.bodyRegular
        }
    }
    
    @IBOutlet private var textView: UITextView! {
        didSet {
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0
        }
    }
    
    @IBOutlet private var galleryContainerView: UIView!
    
    @IBOutlet private var galleryTextStackView: UIStackView!
    
    @IBOutlet private var shortDetailConstraints: [NSLayoutConstraint]!
    
    @IBOutlet private var fullDetailConstraints: [NSLayoutConstraint]!
    
    @IBOutlet private var footerView: UIView!
    
    @IBOutlet private var actionsStackView: UIStackView!
    
    @IBOutlet private var externalLinkButton: UIButton! {
        didSet {
            externalLinkButton
                .configureAsPrimaryActionButton()
                .withTitle(.localized("btn_external_link"))
        }
    }
    
    @IBOutlet private var askQuestionButton: UIButton! {
        didSet {
            askQuestionButton
                .configureAsSecondaryActionButton()
                .withTitle(.localized("btn_ask_a_question"))
        }
    }
    
    private lazy var galleryVC = GalleryCollectionViewController(
        imageSize: CGSize(width: 170, height: 210),
        placeholderImage: .image(withColor: .noiPlaceholderImageColor)
    )
    
    init(newsId: String, viewModel: NewsDetailsViewModel) {
        self.newsId = newsId
        self.viewModel = viewModel
        super.init(nibName: "\(NewsDetailsViewController.self)", bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not available")
    }
    
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("\(#function) not available")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBindings()
        
        refreshControl = .init()
        
        if let news = viewModel.result {
            updateUI(news: news)
        } else {
            viewModel.refreshNewsDetails(newsId: newsId)
        }
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            preferredContentSizeCategoryDidChange(previousPreferredContentSizeCategory: previousTraitCollection?.preferredContentSizeCategory)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let contentInset: UIEdgeInsets
        
        if footerView.superview != nil {
            contentInset = .init(
                top: 0,
                left: 0,
                bottom: footerView.frame.height - view.safeAreaInsets.bottom,
                right: 0
            )
        } else {
            contentInset = .zero
        }
        
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
}

// UITextViewDelegate

extension NewsDetailsViewController: UITextViewDelegate {
    
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
}

// MARK: Private APIs

private extension NewsDetailsViewController {
    
    func configureBindings() {
        externalLinkButton.publisher(for: .primaryActionTriggered)
            .sink { [weak viewModel, externalLinkButton] in
                viewModel?.showExternalLink(sender: externalLinkButton)
            }
            .store(in: &subscriptions)
        
        askQuestionButton.publisher(for: .primaryActionTriggered)
            .sink { [weak viewModel, askQuestionButton] in
                viewModel?.showAskAQuestion(sender: askQuestionButton)
            }
            .store(in: &subscriptions)
        
        refreshControl.publisher(for: .valueChanged)
            .sink { [weak viewModel, newsId] in
                viewModel?.refreshNewsDetails(newsId: newsId)
            }
            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned refreshControl] isLoading in
                refreshControl.isLoading = isLoading
            })
            .store(in: &subscriptions)
        
        viewModel.$result
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.updateUI(news: $0)
            }
            .store(in: &subscriptions)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error = error
                else { return }
                
                self?.showError(error)
            }
            .store(in: &subscriptions)
    }
    
    func updateUI(news: Article?) {
        guard let news = news else {
            containerView.isHidden = true
            footerView.isHidden = true
            return
        }
        
        let author = localizedValue(from: news.languageToAuthor)
        
        imageView.kf.setImage(with: author?.logoURL)
        
        authorLabel.text = author?.name ?? .notDefined
        
        if author?.externalURL == nil {
            externalLinkButton.removeFromSuperview()
        }
        if author?.email == nil {
            askQuestionButton.removeFromSuperview()
        }
        if actionsStackView.subviews.isEmpty {
            footerView.removeFromSuperview()
        }
        
        publishedDateLabel.text = news.date
            .flatMap { publishedDateFormatter.string(from: $0) }
        
        let details = localizedValue(from: news.languageToDetails)
        titleLabel.text = details?.title
        abstractLabel.text = details?.abstract
        
        textView.attributedText = details?.attributedText()?
            .updatedFonts(usingTextStyle: .body)
        
        
        if details?.text == nil {
            textView.removeFromSuperview()
        }
        
        if news.imageGallery.isNilOrEmpty {
            galleryContainerView.removeFromSuperview()
        } else {
            galleryVC.imageURLs = news.imageGallery?.compactMap(\.url) ?? []
            if galleryVC.parent != self {
                embedChild(galleryVC, in: galleryContainerView)
            }
        }
        
        if galleryTextStackView.subviews.isEmpty {
            NSLayoutConstraint.deactivate(fullDetailConstraints)
            NSLayoutConstraint.activate(shortDetailConstraints)
            
            galleryTextStackView.removeFromSuperview()
        }
        
        containerView.isHidden = false
        footerView.isHidden = false
    }
    
    func preferredContentSizeCategoryDidChange(previousPreferredContentSizeCategory: UIContentSizeCategory?) {
        textView.attributedText = textView.attributedText?.updatedFonts(usingTextStyle: .body)
    }
    
}

private extension Article.Details {
    
    func attributedText() -> NSAttributedString? {
        guard let text = text,
              let htmlData = text.data(using: .unicode)
        else { return nil }
        
        return try? NSAttributedString(
            data: htmlData,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        )
    }
    
}

private extension NSAttributedString {

    func updatedFonts(usingTextStyle textStyle: UIFont.TextStyle) -> NSAttributedString {
        let mSelf = NSMutableAttributedString(attributedString: self)
        enumerateAttribute(
            .font,
            in: NSMakeRange(0, length),
            options: [.longestEffectiveRangeNotRequired]
        ) { value, range, stop in
            guard let userFont = value as? UIFont
            else { return }

            let userFontDescriptor = userFont.fontDescriptor
            guard let customFontDescriptor = userFontDescriptor
                .withFamily("Source Sans Pro")
                .withSymbolicTraits(userFontDescriptor.symbolicTraits)
            else {
                fatalError("""
                Failed to load the "Source Sans Pro" family.
                Make sure the family font files is included in the project and the font name is spelled correctly.
                """
                )
            }
            let customFont = UIFont(
                descriptor: customFontDescriptor,
                size: 17
            )
            let dynamicFont = UIFontMetrics(forTextStyle: textStyle)
                .scaledFont(for: customFont)
            mSelf.addAttribute(
                .font,
                value: dynamicFont,
                range: range
            )
        }
        return NSAttributedString(attributedString: mSelf)
    }
    
}
