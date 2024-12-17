// SPDX-FileCopyrightText: NOI Techpark <digital@noi.bz.it>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
//  ThumbnailGenerator.swift
//  NOICommunity
//
//  Created by Camilla on 16/12/24.
//

import UIKit
import AVFoundation

class ThumbnailGenerator {
    
    //let default_url = "https://player.vimeo.com/external/1024278566.m3u8?s=cbcbf4d98e7a731751c7361dd2d037ac1e4aa62e&logging=false"
    
    private struct VimeoResponse: Codable {
        let thumbnail_url_with_play_button: String
    }
    
    static func generateThumbnail() async throws -> URL? {
        let m3u8URL = "https://player.vimeo.com/external/1024278566.m3u8?s=cbcbf4d98e7a731751c7361dd2d037ac1e4aa62e&logging=false"
        
        guard let videoID = extractVideoID(from: m3u8URL) else {
            print("ERRORE: Invalid video ID")
            return nil
        }
        
        guard let jsonURL = getJsonURL(for: videoID) else {
            print("ERRORE: Unable to get JSON URL")
            return nil
        }
        
        // Chiamata asincrona per ottenere l'URL del thumbnail
        let thumbnailURL = await fetchVimeoAPIResponse(from: jsonURL)
        print("thumbnail URL: \(String(describing: thumbnailURL))")

        return thumbnailURL
    }

    
    // url della chiamata per ricavare il json con il link alla thumbnail
    private static func getJsonURL(for videoID: String, width: Int = 315, height: Int = 210) -> String? {
        let vimeoURL = "https://vimeo.com/\(videoID)"
        
        guard let encodedVimeoURL = vimeoURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Errore nella codifica dell'URL Vimeo")
            return nil
        }
        
        let apiURLString = "https://vimeo.com/api/oembed.json?url=\(encodedVimeoURL)&width=\(width)&height=\(height)"
        
        print("url json: \(apiURLString)")
        
        return apiURLString
    }
    
    // funzione per ricavare l'id dall'url del video
    private static func extractVideoID(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string.")
            return nil
        }
        
        // Estrai il percorso dall'URL (la parte dopo il dominio)
        let pathComponents = url.pathComponents
        
        // Verifica che ci sia il segmento "external" nel percorso
        if let externalIndex = pathComponents.firstIndex(of: "external"),
           externalIndex + 1 < pathComponents.count {
            // L'ID del video è il componente che segue "external"
            var videoID = pathComponents[externalIndex + 1]
            
            // Rimuovi l'estensione ".m3u8" se presente
            if let range = videoID.range(of: ".m3u8") {
                videoID.removeSubrange(range)
            }
            
            print("Video ID: \(videoID)") // Stampiamo l'ID estratto
            return videoID
        }
        
        print("Video ID not found")
        return nil
    }

    
    // funzione per recuperare l'url della thumbnail
    private static func fetchVimeoAPIResponse(from apiURL: String) async -> URL? {
        // Creazione dell'URL
        guard let url = URL(string: apiURL) else {
            print("Errore: URL non valido")
            return nil
        }
        
        do {
            // Esegui la richiesta e ottieni i dati
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Verifica se la risposta HTTP è corretta
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                // Prova a decodificare i dati JSON
                let decoder = JSONDecoder()
                do {
                    // Decodifica la risposta JSON
                    let vimeoResponse = try decoder.decode(VimeoResponse.self, from: data)
                    
                    // Converte la stringa in URL
                    if let thumbnailURL = URL(string: vimeoResponse.thumbnail_url_with_play_button) {
                        return thumbnailURL
                    } else {
                        print("Errore: URL thumbnail non valido")
                        return nil
                    }
                } catch {
                    print("Errore durante la decodifica JSON: \(error)")
                    return nil
                }
            } else {
                print("Errore: Risposta HTTP non valida")
                return nil
            }
        } catch {
            print("Errore durante la richiesta: \(error)")
            return nil
        }
    }
}
