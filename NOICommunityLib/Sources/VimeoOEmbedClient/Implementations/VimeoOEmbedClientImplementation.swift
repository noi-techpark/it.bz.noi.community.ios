//
//  File.swift
//  
//
//  Created by Camilla on 23/12/24.
//

import UIKit
import AVFoundation

public class ThumbnailGenerator: ThumbnailGeneratorProtocol {
    
    private struct VimeoResponse: Codable {
        let thumbnail_url_with_play_button: String
    }
    
    /// Generates a thumbnail from a `.m3u8` video URL of a vimeo video
    /// - Parameter m3u8URL: URL of the `.m3u8` video
    /// - Returns: URL of the thumbnail, if available
    public static func generateThumbnail(from videoURL: URL) async -> URL? {
        do {
            let videoID = try extractVideoID(from: videoURL)
            let jsonURL = try getJsonURL(for: videoID)
            let thumbnailURL = try await fetchThumbnailURL(from: jsonURL)
            return thumbnailURL
        } catch {
            print("Error generating thumbnail: \(error)")
            return nil
        }
    }
    
    /// Extracts the video ID from a `.m3u8` video URL of a vimeo video
    /// - Parameter videoURL: URL of the video
    /// - Throws: Error if the ID cannot be extracted
    /// - Returns: The extracted video ID
    private static func extractVideoID(from videoURL: URL) throws -> String {
        let pathComponents = videoURL.pathComponents
        guard let externalIndex = pathComponents.firstIndex(of: "external"),
              externalIndex + 1 < pathComponents.count else {
            throw ThumbnailError.invalidVideoURL
        }
        
        var videoID = pathComponents[externalIndex + 1]
        
        // Remove the `.m3u8` extension if present
        if let range = videoID.range(of: ".m3u8") {
            videoID.removeSubrange(range)
        }
        
        print("Extracted Video ID: \(videoID)")
        return videoID
    }
    
    /// Constructs the JSON API URL to fetch the thumbnail
    /// - Parameter videoID: The ID of the video
    /// - Throws: Error if the API URL cannot be constructed
    /// - Returns: The Vimeo API URL
    private static func getJsonURL(for videoID: String) throws -> URL {
        let vimeoURL = "https://vimeo.com/\(videoID)"
        guard let encodedVimeoURL = vimeoURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw ThumbnailError.invalidVimeoURL
        }
        
        let screenScale = UIScreen.main.scale
        let imageWidth = Int(315 * screenScale) // Calculate the width based on screen scale
        
        var components = URLComponents(string: "https://vimeo.com/api/oembed.json")
        components?.queryItems = [
            URLQueryItem(name: "url", value: encodedVimeoURL),
            URLQueryItem(name: "width", value: "\(imageWidth)")
        ]
        
        guard let apiURL = components?.url else {
            throw ThumbnailError.invalidAPIURL
        }
        
        print("Generated JSON API URL: \(apiURL)")
        return apiURL
    }
    
    /// Makes a request to the Vimeo API to fetch the thumbnail
    /// - Parameter apiURL: The Vimeo API URL
    /// - Throws: Error if the request or decoding fails
    /// - Returns: The URL of the thumbnail
    private static func fetchThumbnailURL(from apiURL: URL) async throws -> URL {
        let (data, response) = try await URLSession.shared.data(from: apiURL)
        
        // Validate the HTTP response status
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ThumbnailError.invalidResponse
        }
        
        // Decode the JSON response
        let decoder = JSONDecoder()
        let vimeoResponse = try decoder.decode(VimeoResponse.self, from: data)
        
        guard let thumbnailURL = URL(string: vimeoResponse.thumbnail_url_with_play_button) else {
            throw ThumbnailError.invalidThumbnailURL
        }
        
        return thumbnailURL
    }
}

enum ThumbnailError: Error {
    case invalidVideoURL
    case invalidVimeoURL
    case invalidAPIURL
    case invalidResponse
    case invalidThumbnailURL
}

