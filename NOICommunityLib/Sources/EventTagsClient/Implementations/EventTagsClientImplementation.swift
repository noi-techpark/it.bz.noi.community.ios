// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  EventTagsClientImplementation.swift
//  NOICommunityLib
//
//  Created by Matteo Matassoni on 03/08/26.
//

import Foundation
import Core

// MARK: -

public enum EventTagsClientCacheKey: Int {
	case eventFilters = 0
}

// MARK: - EventTagsClientImplementation

public final class EventTagsClientImplementation: EventTagsClient {

	private let baseURL: URL

	private let transport: Transport

	private let memoryCache: Cache<EventTagsClientCacheKey, EventTagListResponse>

	private let diskCacheFileURL: URL?

	private let jsonDecoder: JSONDecoder = {
		let jsonDecoder = JSONDecoder()
		jsonDecoder.keyDecodingStrategy = .convertFromPascalCase
		return jsonDecoder
	}()

	public init(
		baseURL: URL,
		transport: Transport,
		memoryCache: Cache<EventTagsClientCacheKey, EventTagListResponse>,
		diskCacheFileURL: URL? = nil
	) {
		self.baseURL = baseURL
		self.transport = transport
			.checkingStatusCodes()
			.addingJSONHeaders()
		self.memoryCache = memoryCache
		self.diskCacheFileURL = diskCacheFileURL
	}

	public func getEventTagList() async throws -> EventTagListResponse {
		let cacheKey: EventTagsClientCacheKey = .eventFilters

		// Check if data is already in memory cache
		if let cachedData = memoryCache[cacheKey] {
			return cachedData
		}

		// Create tasks for loading from disk and API in parallel
		async let diskLoadTask: EventTagListResponse? = loadFromDiskCache()
		async let loadWebAPILoadTask: Result<EventTagListResponse, Error> = loadFromWebAPI()

		// Wait for both tasks to complete
		let (diskResult, webAPIResult) = await (diskLoadTask, loadWebAPILoadTask)

		// Process results based on Web API success/failure
		switch webAPIResult {
		case .success(let apiResponse):
			// API call was successful, update memory cache and return API response
			memoryCache[cacheKey] = apiResponse
			return apiResponse
		case .failure(let webAPIError):
			// API call failed, use disk cache if available
			if let diskResponse = diskResult {
				// Update memory cache with disk data and return
				memoryCache[cacheKey] = diskResponse
				return diskResponse
			}

			// Both API and disk cache failed, rethrow the API error
			throw webAPIError
		}
	}

	// Helper function to load from disk cache
	func loadFromDiskCache() async -> EventTagListResponse? {
		guard let fileURL = diskCacheFileURL else { return nil }

		do {
			let data = try Data(contentsOf: fileURL)
			return try jsonDecoder.decode(EventTagListResponse.self, from: data)
		} catch {
			return nil
		}
	}

	// Helper function to load from API and update disk cache if successfull
	func loadFromWebAPI() async -> Result<EventTagListResponse, Error> {
		do {
			let request = Endpoint
				.eventTagList()
				.makeRequest(withBaseURL: baseURL)

			let (data, _) = try await transport.send(request: request)
			try Task.checkCancellation()

			let response = try jsonDecoder.decode(EventTagListResponse.self, from: data)

			// Save to disk cache
			if let fileURL = diskCacheFileURL {
				try? data.write(to: fileURL)
			}

			return .success(response)
		} catch {
			return .failure(error)
		}
	}

}
