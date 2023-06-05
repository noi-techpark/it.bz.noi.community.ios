// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  UIViewController+ShowCalendarError.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 23/09/2021.
//

import UIKit

extension UIViewController {
    func showCalendarError(_ error: CalendarError) {
        guard case .calendarAccessDeniedOrRestricted = error
        else { return showError(error) }

        let alert = UIAlertController(error: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(
            title: .localized("alert_ok"),
            style: .cancel,
            handler: nil
        )
        alert.addAction(cancelAction)
        let openSettingsAction = UIAlertAction(
            title: .localized("alert_open_settings"),
            style: .default
        ) { _ in
            UIApplication.shared.open(
                URL(string: UIApplication.openSettingsURLString)!,
                options: [:],
                completionHandler: nil
            )
        }
        alert.addAction(openSettingsAction)
        present(alert, animated: true, completion: nil)
    }
}
