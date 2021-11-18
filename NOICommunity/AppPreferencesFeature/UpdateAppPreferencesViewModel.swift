//
//  UpdateAppPreferencesViewModel.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 18/11/21.
//

import Foundation
import Combine
import AppPreferencesClient

class UpdateAppPreferencesViewModel {
    @Published var isLoading = false
    @Published var result: Void?

    private var requestCancellable: AnyCancellable?

    let appPreferencesClient: AppPreferencesClient

    init(appPreferencesClient: AppPreferencesClient) {
        self.appPreferencesClient = appPreferencesClient
    }

    func update(appPreferences: AppPreferences) {
        isLoading = true

        requestCancellable = appPreferencesClient.update(appPreferences)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                },
                receiveValue: { [weak self] in
                    self?.result = $0
                }
            )
    }
}
