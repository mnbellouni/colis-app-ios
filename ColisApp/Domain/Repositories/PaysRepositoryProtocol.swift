import Foundation

protocol PaysRepository {
    func getPays() async throws -> [Pays]
}
