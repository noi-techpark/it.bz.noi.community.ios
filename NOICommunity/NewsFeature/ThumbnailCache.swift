//
//  ThumbnailCache.swift
//  NOICommunity
//
//  Created by Camilla on 23/12/24.
//

import Foundation

final class ThumbnailCache {
    
    private static var cache: [URL: URL] = [:]
    
    static func getThumbnail(for videoURL: URL) -> URL? {
        return cache[videoURL]
    }
    
    static func setThumbnail(_ thumbnailURL: URL, for videoURL: URL) {
        cache[videoURL] = thumbnailURL
    }
}
