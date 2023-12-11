//
//  ComeOnBoardOnboardingViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 11/12/23.
//

import Foundation
import Combine
import AppPreferencesClient

final class ComeOnBoardOnboardingViewModel {

    lazy var navigateToMainAppPublisher = navigateToMainAppSubject
        .eraseToAnyPublisher()

    @Published private(set) var isDontShowThisAgainToggleOn = false

    private var navigateToMainAppSubject: PassthroughSubject<Void, Never> = .init()

    private let appPreferencesClient: AppPreferencesClient

    private lazy var appPreferences = appPreferencesClient.fetch()

    init(appPreferencesClient: AppPreferencesClient) {
        self.appPreferencesClient = appPreferencesClient
    }

    func navigateToMainApp() {
        appPreferences.skipComeOnBoardOnboarding = isDontShowThisAgainToggleOn
        appPreferencesClient.update(appPreferences)

        navigateToMainAppSubject.send(())
    }

    func toggleDontShowThisAgainToggleOn() {
        isDontShowThisAgainToggleOn.toggle()
    }
}
