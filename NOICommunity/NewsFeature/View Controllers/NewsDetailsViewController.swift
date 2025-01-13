// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  NewsDetailViewController.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/05/22.
//

import UIKit
import Combine
import Core
import CoreUI
import ArticlesClient
import VimeoVideoThumbnailClient

class NewsDetailsViewController: UIViewController {

	let news: Article

    var externalLinkActionHandler: ((Article) -> Void)?
    
    var askQuestionActionHandler: ((Article) -> Void)?

	private let dependencyContainer: DependencyRepresentable

	private var subscriptions: Set<AnyCancellable> = []

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
		imageSize: CGSize(
			width: SizeAndConstants.galleryItemWidth,
			height: SizeAndConstants.galleryItemHeight
		),
		spacing: SizeAndConstants.galleryItemSpacing,
        placeholderImage: .image(withColor: .noiPlaceholderImageColor)
    )

	private lazy var vimeoVideoThumbnailClient = dependencyContainer.makeVimeoVideoThumbnailClient()

	init(for item: Article, dependencyContainer: DependencyRepresentable) {
		self.news = item
		self.dependencyContainer = dependencyContainer
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

	override func viewDidLoad() {
		super.viewDidLoad()

		configureBindings()

		imageView.kf.setImage(with: news.author?.logoURL)

		authorLabel.text = news.author?.name ?? .notDefined

		if news.author?.externalURL == nil {
			externalLinkButton.removeFromSuperview()
		}
		if news.author?.email == nil {
			askQuestionButton.removeFromSuperview()
		}
		if actionsStackView.subviews.isEmpty {
			footerView.removeFromSuperview()
		}

		publishedDateLabel.text = news.date
			.flatMap { publishedDateFormatter.string(from: $0) }

		titleLabel.text = news.details?.title
		abstractLabel.text = news.details?.abstract

		textView.attributedText = news.details?.attributedText()?
			.updatedFonts(usingTextStyle: .body)


		if news.details?.text == nil {
			textView.removeFromSuperview()
		}

		if news.imageGallery.isEmpty && news.videoGallery.isEmpty {
            galleryContainerView.removeFromSuperview()
        } else {
            if galleryVC.parent != self {
                embedChild(galleryVC, in: galleryContainerView)
            }

			galleryVC.mediaItems = news.imageGallery
				.compactMap(\.url)
				.map { MediaItem(imageURL: $0) }

			foo()
		}

		if galleryTextStackView.subviews.isEmpty {
			NSLayoutConstraint.deactivate(fullDetailConstraints)
			NSLayoutConstraint.activate(shortDetailConstraints)

			galleryTextStackView.removeFromSuperview()
		}
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
            .sink { [weak self] in
				guard let self
				else { return }

				self.externalLinkActionHandler?(self.news)
            }
            .store(in: &subscriptions)
        
        askQuestionButton.publisher(for: .primaryActionTriggered)
			.sink { [weak self] in
				guard let self
				else { return }

				self.askQuestionActionHandler?(self.news)
			}
            .store(in: &subscriptions)
    }
    

    func preferredContentSizeCategoryDidChange(
		previousPreferredContentSizeCategory: UIContentSizeCategory?
	) {
        textView.attributedText = textView.attributedText?.updatedFonts(usingTextStyle: .body)
    }

	func foo() {
		let imageURLs = news.imageGallery
			.compactMap(\.url)
		let videosURLs = news.videoGallery.compactMap(\.url)
		let screenScale = UIScreen.main.scale

		Task(priority: .userInitiated) {
			let pixelWidth = Int((SizeAndConstants.galleryItemWidth * screenScale)
				.rounded(.up))
			let pixelHeight = Int((SizeAndConstants.galleryItemHeight * screenScale)
				.rounded(.up))

			let videoURLToThumbnailURL = await vimeoVideoThumbnailClient.fetchThumbnailURLs(
				from: videosURLs,
				width: pixelWidth,
				height: pixelHeight
			)

			let thumbnailURLs = videosURLs.compactMap { videoURLToThumbnailURL[$0] }

			let videoItems: [MediaItem] = videosURLs.map { videoURL in
				MediaItem(
					imageURL: videoURLToThumbnailURL[videoURL] ?? nil,
					videoURL: videoURL)
			}
			let imageItems: [MediaItem] = imageURLs.map { imageURL in
				MediaItem(imageURL: imageURL)
			}

			Task(priority: .userInitiated) { @MainActor in
				galleryVC.mediaItems = videoItems + imageItems
			}
		}
	}

	func performFoo() async {




		// Creiamo una lista sincrona per le immagini
		let imageList: [MediaItem] = news.imageGallery.compactMap { image in
			guard let imageURL = image.url else { return nil }
			return MediaItem(imageURL: imageURL, videoURL: nil)
		}

		// Creiamo una lista sincrona per i video
		var videoList: [MediaItem] = []
		for video in news.videoGallery {
			guard let videoURL = video.url else { continue }

			if let thumbnailURL = try? await vimeoVideoThumbnailClient.fetchThumbnailURL(
				from: videoURL,
				width: Int((SizeAndConstants.galleryItemWidth * UIScreen.main.scale).rounded(.up)),
				height: Int((SizeAndConstants.galleryItemHeight * UIScreen.main.scale).rounded(.up))
			) {
				videoList.append(MediaItem(imageURL: thumbnailURL, videoURL: videoURL))
			} else {
				// Se fallisce, aggiungi comunque il MediaItem con solo videoURL
				videoList.append(MediaItem(imageURL: nil, videoURL: videoURL))
			}
		}

		// Unisci video e immagini
		galleryVC.mediaItems = videoList + imageList
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

private extension Article {

	var author: ContactInfos? { localizedValue(from: languageToAuthor) }

	var details: Details? { localizedValue(from: languageToDetails) }

	var videoGallery: [VideoGallery] { localizedValue(from: languageToVideoGallery) ?? [] }

}

private extension SizeAndConstants {

	static let galleryItemWidth: CGFloat = 315
	static let galleryItemHeight: CGFloat = 210
	static let galleryItemSpacing: CGFloat = 17
}
