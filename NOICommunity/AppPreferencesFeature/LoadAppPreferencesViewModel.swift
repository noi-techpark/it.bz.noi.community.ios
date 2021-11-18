//
//  AppPreferencesViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 18/11/21.
//

import Foundation
import Combine
import AppPreferencesClient

class LoadAppPreferencesViewModel {
    @Published var isLoading = false
    @Published var appPreferences: AppPreferences?

    private var requestCancellable: AnyCancellable?

    let appPreferencesClient: AppPreferencesClient

    init(appPreferencesClient: AppPreferencesClient) {
        self.appPreferencesClient = appPreferencesClient
    }

    func load() {
        isLoading = true
        appPreferences = nil

        requestCancellable = appPreferencesClient.fetch()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                },
                receiveValue: { [weak self] in
                    self?.appPreferences = $0
                })
    }
}
