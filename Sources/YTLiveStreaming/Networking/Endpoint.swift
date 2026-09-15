import Foundation

/// A fully described API call: method, path under the base URL, query and JSON body.
struct Endpoint: Sendable, Equatable {
    enum Method: String, Sendable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    var method: Method
    var path: String
    var query: [URLQueryItem] = []
    var body: Data?

    /// Builds the request. `parts` are appended as the `part` query item, `apiKey` as `key`.
    func urlRequest(baseURL: URL, apiKey: String?, bundleIdentifier: String?, token: String) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw YouTubeLiveError.invalidResponse
        }
        var items = query
        if let apiKey, !apiKey.isEmpty {
            items.append(URLQueryItem(name: "key", value: apiKey))
        }
        components.queryItems = items.isEmpty ? nil : items
        guard let url = components.url else { throw YouTubeLiveError.invalidResponse }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let bundleIdentifier, !bundleIdentifier.isEmpty {
            // Required when the API key is restricted to iOS apps in the Google Cloud console.
            request.setValue(bundleIdentifier, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        }
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
}

// MARK: - Resource parts

/// The `part` parameter values the YouTube Data API accepts for each resource.
enum Parts {
    static let broadcast = "id,snippet,contentDetails,status"
    static let stream = "id,snippet,cdn,status,contentDetails"
}

extension Endpoint {
    static func part(_ value: String) -> URLQueryItem { URLQueryItem(name: "part", value: value) }
}
