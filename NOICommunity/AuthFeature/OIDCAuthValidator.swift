// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  OIDCAuthValidator.swift
//  NOICommunity
//
//  Created by Matteo Matassoni on 12/11/25.
//

import Foundation
import AuthStateStorageClient
import AppAuth

public protocol OIDCAuthValidator {
	func validate() -> Bool
}

public final class LiveOIDCAuthValidator<Storage: AuthStateStorageClient>: OIDCAuthValidator where Storage.AuthState == OIDAuthState {

	private let tokenStorage: Storage
	private let clientID: String

	public init(
		tokenStorage: Storage,
		clientID: String
	) {
		self.tokenStorage = tokenStorage
		self.clientID = clientID
	}

	/// Validates the authentication state against the expected client ID.
	///
	/// If validation fails, the stored auth state will be automatically cleared
	/// to prevent using invalid credentials.
	///
	/// - Returns: `true` if the auth state is valid and matches the expected client ID, `false` otherwise.
	public func validate() -> Bool {
		guard let authState = tokenStorage.state else {
			return true
		}

		let isValid = validateAuthState(authState, expectedClientID: clientID)
		if !isValid {
			tokenStorage.state = nil
		}
		return isValid
	}
}

private extension LiveOIDCAuthValidator {

	/// Validates whether the current authentication state matches the expected client ID.
	///
	/// - Parameters:
	///   - authState: The current `OIDAuthState` to validate.
	///   - expectedClientID: The client ID that the auth state should match.
	/// - Returns: `true` if the client IDs match, `false` otherwise.
	func validateAuthState(
		_ authState: OIDAuthState,
		expectedClientID: String
	) -> Bool {
		// Prefer the most recent client ID (from token response if available)
		let currentClientID = authState.lastTokenResponse?.request.clientID
		?? authState.lastAuthorizationResponse.request.clientID

		return currentClientID == expectedClientID
	}
}
