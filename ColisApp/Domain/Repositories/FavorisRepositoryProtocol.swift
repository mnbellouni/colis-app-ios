import Foundation

protocol FavorisRepository {
    func getMesFavoris() async throws -> [Annonce]
    func addFavori(annonceId: String) async throws
    func removeFavori(annonceId: String) async throws
    func isFavori(annonceId: String) async throws -> Bool
}
