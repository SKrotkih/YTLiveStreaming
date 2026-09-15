import Foundation

/// The error payload Google APIs return for non-2xx responses.
///
/// ```json
/// { "error": { "code": 403, "message": "…", "status": "PERMISSION_DENIED",
///              "errors": [ { "domain": "youtube.liveBroadcast", "reason": "…", "message": "…" } ] } }
/// ```
public struct GoogleAPIError: Decodable, Sendable, Equatable {
    public struct Detail: Decodable, Sendable, Equatable {
        public let domain: String?
        public let reason: String?
        public let message: String?
        public let location: String?
        public let locationType: String?
    }

    public let code: Int
    public let message: String
    public let status: String?
    public let errors: [Detail]

    /// The `reason` of the first detail, e.g. `"quotaExceeded"`, `"liveBroadcastNotFound"`,
    /// `"errorStreamInactive"`, `"invalidTransition"`. Handy for `switch`ing on API failures.
    public var reason: String? { errors.first?.reason }

    private struct Envelope: Decodable {
        let error: GoogleAPIError
    }

    enum CodingKeys: String, CodingKey {
        case code, message, status, errors
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        message = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
        status = try container.decodeIfPresent(String.self, forKey: .status)
        errors = try container.decodeIfPresent([Detail].self, forKey: .errors) ?? []
    }

    public init(code: Int, message: String, status: String? = nil, errors: [Detail] = []) {
        self.code = code
        self.message = message
        self.status = status
        self.errors = errors
    }

    /// Parses a Google error envelope from a response body, if the body is one.
    static func parse(_ data: Data) -> GoogleAPIError? {
        try? JSONDecoder().decode(Envelope.self, from: data).error
    }
}

/// Every error thrown by ``YouTubeLiveClient``.
public enum YouTubeLiveError: Error, Sendable {
    /// The ``TokenProvider`` had no token to offer (user not signed in).
    case missingAccessToken
    /// HTTP 401 after the token-refresh attempt (if any). Sign the user in again.
    case unauthorized(GoogleAPIError?)
    /// HTTP 403: insufficient scopes, live streaming not enabled on the channel, quota exceeded, …
    case forbidden(GoogleAPIError?)
    /// HTTP 404: the broadcast/stream does not exist (or is not owned by the signed-in channel).
    case notFound(GoogleAPIError?)
    /// Any other non-2xx status that carried a Google error payload.
    case api(statusCode: Int, GoogleAPIError)
    /// A non-2xx status with a body that is not a Google error payload.
    case http(statusCode: Int, body: Data)
    /// The response body could not be decoded into the expected model.
    case decoding(underlying: any Error, body: Data)
    /// URLSession (or the injected transport) failed before a response arrived.
    case transport(any Error)
    /// The transport returned something that is not an HTTP response.
    case invalidResponse

    /// The Google error payload, when the failure carried one.
    public var apiError: GoogleAPIError? {
        switch self {
        case .unauthorized(let error), .forbidden(let error), .notFound(let error):
            return error
        case .api(_, let error):
            return error
        default:
            return nil
        }
    }

    /// The HTTP status code, when the failure was an HTTP response.
    public var statusCode: Int? {
        switch self {
        case .unauthorized: return 401
        case .forbidden: return 403
        case .notFound: return 404
        case .api(let code, _), .http(let code, _): return code
        default: return nil
        }
    }

    /// Maps an HTTP status + body to the matching case. Only called for non-2xx responses.
    static func from(statusCode: Int, body: Data) -> YouTubeLiveError {
        let apiError = GoogleAPIError.parse(body)
        switch statusCode {
        case 401: return .unauthorized(apiError)
        case 403: return .forbidden(apiError)
        case 404: return .notFound(apiError)
        default:
            if let apiError { return .api(statusCode: statusCode, apiError) }
            return .http(statusCode: statusCode, body: body)
        }
    }
}

extension YouTubeLiveError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingAccessToken:
            return "No Google access token is available. Sign in first."
        case .unauthorized(let error):
            return "Unauthorized (401). \(error?.message ?? "The access token is missing, expired or revoked.")"
        case .forbidden(let error):
            return "Forbidden (403). \(error?.message ?? "Check the OAuth scopes, quota, and that live streaming is enabled on the channel.")"
        case .notFound(let error):
            return "Not found (404). \(error?.message ?? "The broadcast or stream does not exist.")"
        case .api(let code, let error):
            return "YouTube API error \(code): \(error.message)"
        case .http(let code, let body):
            let text = String(data: body.prefix(512), encoding: .utf8) ?? "<\(body.count) bytes>"
            return "HTTP \(code): \(text)"
        case .decoding(let underlying, _):
            return "Could not decode the YouTube API response: \(underlying)"
        case .transport(let underlying):
            return "Network error: \(underlying.localizedDescription)"
        case .invalidResponse:
            return "The server returned a non-HTTP response."
        }
    }
}
