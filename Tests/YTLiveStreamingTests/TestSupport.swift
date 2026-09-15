import Foundation
import XCTest
@testable import YTLiveStreaming

/// A transport that answers from a queue of canned responses and records every request.
actor MockTransport: HTTPTransport {
    struct Canned {
        var status: Int
        var body: Data
    }

    private var queue: [Canned]
    private(set) var requests: [URLRequest] = []

    init(_ responses: [Canned] = []) {
        self.queue = responses
    }

    func enqueue(status: Int = 200, body: Data) {
        queue.append(Canned(status: status, body: body))
    }

    func enqueue(status: Int = 200, fixture: String) throws {
        queue.append(Canned(status: status, body: try Fixtures.data(fixture)))
    }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        requests.append(request)
        guard !queue.isEmpty else {
            XCTFail("Unexpected request: \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "?")")
            throw YouTubeLiveError.invalidResponse
        }
        let canned = queue.removeFirst()
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: canned.status,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        return (canned.body, response)
    }
}

enum Fixtures {
    static func data(_ name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures") else {
            throw NSError(domain: "Fixtures", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing fixture \(name).json"])
        }
        return try Data(contentsOf: url)
    }
}

/// A token provider that counts calls and can simulate a refresh.
actor CountingTokenProvider: TokenProvider {
    private(set) var accessCalls = 0
    private(set) var refreshCalls = 0
    private let refreshed: String?

    init(refreshed: String? = nil) {
        self.refreshed = refreshed
    }

    func accessToken() async throws -> String {
        accessCalls += 1
        return "token-\(accessCalls)"
    }

    func refreshAccessToken() async throws -> String? {
        refreshCalls += 1
        return refreshed
    }
}

extension URLRequest {
    var queryItems: [String: String] {
        guard let url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return [:] }
        return Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })
    }

    var jsonBody: [String: Any] {
        guard let httpBody,
              let object = try? JSONSerialization.jsonObject(with: httpBody) as? [String: Any] else { return [:] }
        return object
    }
}

func makeClient(_ transport: MockTransport, tokenProvider: any TokenProvider = StaticTokenProvider("t0k3n")) -> YouTubeLiveClient {
    YouTubeLiveClient(
        tokenProvider: tokenProvider,
        configuration: .init(apiKey: "API-KEY", bundleIdentifier: "com.example.app"),
        transport: transport
    )
}
