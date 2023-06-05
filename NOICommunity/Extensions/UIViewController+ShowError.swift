// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  UIViewController+ShowError.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 21/09/2021.
//

import UIKit

extension UIViewController {
    
    func showError(
        _ error: Error,
        presentationCompletion: (() -> Void)? = nil,
        dismissCompletion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(error: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(
            title: .localized("alert_ok"),
            style: .cancel
        ) { _ in
            dismissCompletion?()
        }
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: presentationCompletion)
    }
    
}
