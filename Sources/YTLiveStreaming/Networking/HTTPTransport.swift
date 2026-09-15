import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// The single seam between ``YouTubeLiveClient`` and the network.
///
/// `URLSession` conforms out of the box; tests inject a recording mock.
public protocol HTTPTransport: Sendable {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

extension URLSession: HTTPTransport {
    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let body: Data
        let response: URLResponse
        do {
            (body, response) = try await self.data(for: request)
        } catch {
            throw YouTubeLiveError.transport(error)
        }
        guard let http = response as? HTTPURLResponse else {
            throw YouTubeLiveError.invalidResponse
        }
        return (body, http)
    }
}
