//
//  File.swift
//  
//
//  Created by Camilla on 23/12/24.
//


import Foundation

protocol ThumbnailGeneratorProtocol {
    static func generateThumbnail(from videoURL: URL) async -> URL?
}
