// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  UIApplication+URL.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 30/05/22.
//

import UIKit

extension URL {
    
    init?(phoneNumber: String) {
        guard let escapedPhoneNumber = phoneNumber.addingPercentEncoding(
            withAllowedCharacters: .urlHostAllowed
        )
        else { return nil }
        
        self.init(string: "tel://\(escapedPhoneNumber)")
    }
    
    var isTel: Bool {
        scheme == "tel"
    }
    
}

extension URL {
    
    init?(mailTo email: String) {
        self.init(string: "mailto:\(email)")
    }
    
    var isMailTo: Bool {
        guard let component = absoluteString.split(separator: ":").first
        else { return false }
        return component == "mailto"
    }
    
}

extension UIApplication {
    
    open func canMail(to email: String) -> Bool {
        guard let mailToUrl = URL(mailTo: email)
        else { return false }
        
        return canOpenURL(mailToUrl)
    }
    
    open func composeMail(
        to email: String,
        completionHandler completion: ((Bool) -> Void)? = nil
    ) {
        guard let mailToUrl = URL(mailTo: email)
        else { completion?(false); return }
        
        open(mailToUrl,
             options: [:],
             completionHandler: completion)
    }
    
}

extension UIApplication {
    
    open func canPhone(_ phoneNumber: String) -> Bool {
        guard let phoneUrl = URL(phoneNumber: phoneNumber)
        else { return false }
        
        return canOpenURL(phoneUrl)
    }
    
    open func phone(
        _ phoneNumber: String,
        completionHandler completion: ((Bool) -> Void)? = nil
    ) {
        guard let phoneUrl = URL(phoneNumber: phoneNumber)
        else { completion?(false); return }
        
        open(phoneUrl,
             options: [:],
             completionHandler: completion)
    }
    
}
