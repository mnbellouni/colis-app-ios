import Foundation

protocol PaysRepository {
    func getConfig() async throws -> RemoteConfig
}
