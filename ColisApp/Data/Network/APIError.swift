//
//  APIError 2.swift
//  ColisApp
//
//  Created by Nadjib Bellouni on 26/04/2026.
//


import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int, String)
    case unauthorized
    case networkError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL invalide"
        case .noData:
            return "Aucune donnée reçue"
        case .decodingError(let error):
            return "Erreur de décodage : \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Erreur serveur \(code) : \(message)"
        case .unauthorized:
            return "Non autorisé — veuillez vous reconnecter"
        case .networkError(let error):
            return "Erreur réseau : \(error.localizedDescription)"
        case .unknown:
            return "Erreur inconnue"
        }
    }
}

