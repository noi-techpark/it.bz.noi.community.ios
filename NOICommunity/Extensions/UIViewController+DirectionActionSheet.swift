//
//  UIViewController+DirectionActionSheet.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 31/05/22.
//

import UIKit

extension UIAlertController {
    
    static func make(
        destinationName: String,
        destinationAddress: String,
        directionCompletion: (() -> Void)? = nil,
        application: UIApplication = .shared
    ) -> UIAlertController {
        let alertController = UIAlertController(
            title: destinationName,
            message: destinationAddress,
            preferredStyle: .actionSheet
        )
        
        let cancelAction = UIAlertAction(
            title: .localized("cancel_label"),
            style: .cancel
        ) { _ in
                directionCompletion?()
            }
        alertController.addAction(cancelAction)
        
        if let appleMapsUrlScheme = URL(string: "maps://"),
           application.canOpenURL(appleMapsUrlScheme) {
            let appleMapsDirectionsAction = UIAlertAction(
                title: .localized("apple_maps_button"),
                style: .default
            ) { _ in
                let openUrlCompletion: (Bool) -> Void = { _ in
                    directionCompletion?()
                }
                var urlComponents = URLComponents(
                    string: "http://maps.apple.com/"
                )
                urlComponents?.queryItems = [
                    URLQueryItem(
                        name: "daddr",
                        value: destinationAddress
                    )
                ]
                if let mapUrl = urlComponents?.url {
                    application.open(
                        mapUrl,
                        options: [:],
                        completionHandler: openUrlCompletion
                    )
                } else {
                    directionCompletion?()
                }
            }
            alertController.addAction(appleMapsDirectionsAction)
        }
        
        if let googleMapsUrlScheme = URL(string: "comgooglemaps://"),
           application.canOpenURL(googleMapsUrlScheme) {
            let googleMapsDirectionsAction = UIAlertAction(
                title: .localized("google_maps_button"),
                style: .default
            ) { _ in
                let openUrlCompletion: (Bool) -> Void = { _ in
                    directionCompletion?()
                }
                var urlComponents = URLComponents(
                    string: "https://www.google.com/maps/dir/"
                )
                urlComponents?.queryItems = [
                    URLQueryItem(name: "api", value: "1"),
                    URLQueryItem(name: "destination", value: destinationAddress)
                ]
                if let mapUrl = urlComponents?.url {
                    application.open(
                        mapUrl,
                        options: [:],
                        completionHandler: openUrlCompletion
                    )
                } else {
                    directionCompletion?()
                }
            }
            alertController.addAction(googleMapsDirectionsAction)
        }
        
        if let wazeMapsUrlScheme = URL(string: "waze://"),
           application.canOpenURL(wazeMapsUrlScheme) {
            let wazeDirectionsAction = UIAlertAction(
                title: .localized("waze_button"),
                style: .default
            ) { _ in
                let openUrlCompletion: (Bool) -> Void = { _ in
                    directionCompletion?()
                }
                var urlComponents = URLComponents(
                    string: "https://waze.com/ul/"
                )
                urlComponents?.queryItems = [
                    URLQueryItem(name: "q", value: destinationAddress)
                ]
                if let mapUrl = urlComponents?.url {
                    application.open(
                        mapUrl,
                        options: [:],
                        completionHandler: openUrlCompletion
                    )
                } else {
                    directionCompletion?()
                }
            }
            alertController.addAction(wazeDirectionsAction)
        }
        
        return alertController
    }
    
}

extension UIViewController {
    
    func showDirectionActionSheet(
        destinationName: String,
        destinationAddress: String,
        animated: Bool,
        directionCompletion: (() -> Void)? = nil,
        application: UIApplication = .shared
    ) {
        let directionActionSheet = UIAlertController.make(
            destinationName: destinationName,
            destinationAddress: destinationAddress,
            directionCompletion: directionCompletion,
            application: application
        )
        present(directionActionSheet, animated: animated)
    }
    
}
