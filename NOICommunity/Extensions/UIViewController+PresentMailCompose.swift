// Copyright © 2022 DIMENSION S.r.l. All rights reserved.
// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import UIKit
import MessageUI

struct EmailParameters {
    /// Guaranteed to be non-empty
    let toEmails: [String]
    let ccEmails: [String]
    let bccEmails: [String]
    let subject: String?
    let body: String?
    
    /// Defaults validation is just verifying that the email is not empty.
    static func defaultValidateEmail(_ email: String) -> Bool {
        !email.isEmpty
    }
    
    /// Returns `nil` if `toEmails` contains at least one email address validated by `validateEmail`
    /// A "blank" email address is defined as an address that doesn't only contain whitespace and new lines characters, as defined by CharacterSet.whitespacesAndNewlines
    /// `validateEmail`'s default implementation is `defaultValidateEmail`.
    init?(
        toEmails: [String],
        ccEmails: [String] = [],
        bccEmails: [String] = [],
        subject: String? = nil,
        body: String? = nil,
        validateEmail: (String) -> Bool = defaultValidateEmail
    ) {
        func parseEmails(_ emails: [String]) -> [String] {
            emails.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter(validateEmail)
        }
        let toEmails = parseEmails(toEmails)
        let ccEmails = parseEmails(ccEmails)
        let bccEmails = parseEmails(bccEmails)
        if toEmails.isEmpty {
            return nil
        }
        self.toEmails = toEmails
        self.ccEmails = ccEmails
        self.bccEmails = bccEmails
        self.subject = subject
        self.body = body
    }
    
    /// Returns `nil` if `scheme` is not `mailto`, or if it couldn't find any `to` email addresses
    /// `validateEmail`'s default implementation is `defaultValidateEmail`.
    /// Reference:  https://tools.ietf.org/html/rfc2368
    init?(url: URL, validateEmail: (String) -> Bool = defaultValidateEmail) {
        guard url.scheme == "mailto"
        else { return nil }
        
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        let queryItems = urlComponents.queryItems ?? []
        func splitEmail(_ email: String) -> [String] {
            email.split(separator: ",").map(String.init)
        }
        let initialParameters = (
            toEmails: urlComponents.path.isEmpty ? [] : splitEmail(urlComponents.path),
            subject: String?(nil),
            body: String?(nil),
            ccEmails: [String](),
            bccEmails: [String]()
        )
        let emailParameters = queryItems.reduce(into: initialParameters) { emailParameters, queryItem in
            guard let value = queryItem.value
            else { return }
            switch queryItem.name {
            case "to":
                emailParameters.toEmails += splitEmail(value)
            case "cc":
                emailParameters.ccEmails += splitEmail(value)
            case "bcc":
                emailParameters.bccEmails += splitEmail(value)
            case "subject" where emailParameters.subject == nil:
                emailParameters.subject = value
            case "body" where emailParameters.body == nil:
                emailParameters.body = value
            default:
                break
            }
        }
        self.init(
            toEmails: emailParameters.toEmails,
            ccEmails: emailParameters.ccEmails,
            bccEmails: emailParameters.bccEmails,
            subject: emailParameters.subject,
            body: emailParameters.body,
            validateEmail: validateEmail
        )
    }
    
    func mailtoUrl() -> URL? {
        guard !toEmails.isEmpty
        else { return nil }
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "mailto"
        urlComponents.path = toEmails.joined(separator: ",")
        var queryItems: [URLQueryItem] = []
        if !ccEmails.isEmpty {
            let ccQueryItem = URLQueryItem(
                name: "cc",
                value: ccEmails.joined(separator: ",")
            )
            queryItems.append(ccQueryItem)
        }
        if !bccEmails.isEmpty {
            let bccQueryItem = URLQueryItem(
                name: "bcc",
                value: bccEmails.joined(separator: ",")
            )
            queryItems.append(bccQueryItem)
        }
        if let subject = subject, !subject.isEmpty {
            let subjectQueryItem = URLQueryItem(
                name: "subject",
                value: subject
            )
            queryItems.append(subjectQueryItem)
        }
        if let body = body, !body.isEmpty {
            let bodyQueryItem = URLQueryItem(
                name: "body",
                value: body
            )
            queryItems.append(bodyQueryItem)
        }
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
}


extension UIViewController {
    
    func mailTo(
        _ email: String,
        application _: UIApplication = .shared,
        delegate: MFMailComposeViewControllerDelegate?,
        completion: (() -> Void)?
    ) {
        guard let mailToURL = URL(string: "mailto:\(email)")
        else { return }
        
        mailTo(mailToURL, delegate: delegate, completion: completion)
    }
    
    func mailTo(
        _ url: URL,
        application _: UIApplication = .shared,
        delegate: MFMailComposeViewControllerDelegate?,
        completion: (() -> Void
        )?
    ) {
        guard let emailParameters = EmailParameters(url: url)
        else { return }
        
        mailTo(emailParameters, delegate: delegate, completion: completion)
    }
    
    func mailTo(
        _ emailParameters: EmailParameters,
        application: UIApplication = .shared,
        delegate: MFMailComposeViewControllerDelegate?,
        completion: (() -> Void)?
    ) {
        if MFMailComposeViewController.canSendMail() {
            composeEmail(
                emailParameters,
                delegate: delegate,
                completion: completion
            )
        } else if let mailtoUrl = emailParameters.mailtoUrl() {
            application.open(
                mailtoUrl,
                options: [:]
            ) { success in
                if success {
                    completion?()
                }
            }
        }
    }
    
    private func composeEmail(
        _ parameters: EmailParameters,
        delegate: MFMailComposeViewControllerDelegate?,
        completion: (() -> Void)?
    ) {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = delegate
        mailComposeViewController.setToRecipients(parameters.toEmails)
        if let subject = parameters.subject {
            mailComposeViewController.setSubject(subject)
        }
        if let body = parameters.body {
            mailComposeViewController.setMessageBody(body, isHTML: false)
        }
        present(
            mailComposeViewController,
            animated: true,
            completion: completion
        )
    }
    
}
