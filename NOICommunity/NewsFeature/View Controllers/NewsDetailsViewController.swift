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
import ArticlesClient

class NewsDetailsViewController: UIViewController {

	let news: Article

    var externalLinkActionHandler: ((Article) -> Void)?
    
    var askQuestionActionHandler: ((Article) -> Void)?

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
    
    // A cache that stores thumbnail URLs for video URLs to avoid redundant processing.
    private static var thumbnailCache: [URL: URL] = [:]
    
    private lazy var galleryVC = GalleryCollectionViewController(
        imageSize: CGSize(width: 315, height: 210),
        spacing: 17,
        placeholderImage: .image(withColor: .noiPlaceholderImageColor)
    )

	init(for item: Article) {
		self.news = item
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

        let localizedVideoList = localizedValue(from: news.languageToVideoGallery) ?? []
        if news.imageGallery.isEmpty && localizedVideoList.isEmpty {
            galleryContainerView.removeFromSuperview()
        } else {
            // Crea la lista sincrona per le immagini
            let imageList: [MediaItem] = news.imageGallery.compactMap { image in
                guard let imageURL = image.url else { return nil }
                return MediaItem(imageURL: imageURL, videoURL: nil)
            }

            // Crea la lista iniziale per i video, con solo videoURL
            let initialVideoList: [MediaItem] = localizedVideoList.compactMap { video in
                guard let videoURL = video.url else { return nil }
                // Controlla se c'è già un URL nella cache per la thumbnail
                let cachedThumbnailURL = Self.thumbnailCache[videoURL]
                return MediaItem(imageURL: cachedThumbnailURL, videoURL: videoURL) // Solo videoURL per ora
            }
            
            // Imposta gli elementi iniziali su galleryVC.mediaItems
            galleryVC.mediaItems = initialVideoList + imageList

            if galleryVC.parent != self {
                embedChild(galleryVC, in: galleryContainerView)
            }
            Task {
                // Creiamo una lista sincrona per le immagini
                let imageList: [MediaItem] = news.imageGallery.compactMap { image in
                    guard let imageURL = image.url else { return nil }
                    return MediaItem(imageURL: imageURL, videoURL: nil)
                }
                
                // Creiamo una lista sincrona per i video
                var videoList: [MediaItem] = []
                for video in localizedVideoList {
                    guard let videoURL = video.url else { continue }
                    
                    if let cachedThumbnailURL = Self.thumbnailCache[videoURL] {
                        videoList.append(MediaItem(imageURL: cachedThumbnailURL, videoURL: videoURL))
                    } else {
                        if let thumbnailURL = await ThumbnailGenerator.generateThumbnail(from: videoURL) {
                            Self.thumbnailCache[videoURL] = thumbnailURL
                            videoList.append(MediaItem(imageURL: thumbnailURL, videoURL: videoURL))
                        } else {
                            // Se fallisce, aggiungi comunque il MediaItem con solo videoURL
                            videoList.append(MediaItem(imageURL: nil, videoURL: videoURL))
                        }
                    }
                }

                // Unisci video e immagini
                galleryVC.mediaItems = videoList + imageList
                
                if galleryVC.parent != self {
                    embedChild(galleryVC, in: galleryContainerView)
                }
            }
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
