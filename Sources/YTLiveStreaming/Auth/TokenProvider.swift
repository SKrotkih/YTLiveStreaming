import Foundation

/// Supplies the OAuth 2.0 access token used to authorize every request.
///
/// The library deliberately does not perform Google Sign-In itself: the host app owns the
/// sign-in flow (GoogleSignIn SDK, AppAuth, a backend, …) and exposes the resulting token
/// through this protocol. Implementations must be safe to call from any task.
///
/// ```swift
/// struct GIDTokenProvider: TokenProvider {
///     func accessToken() async throws -> String {
///         guard let user = GIDSignIn.sharedInstance.currentUser else {
///             throw YouTubeLiveError.missingAccessToken
///         }
///         return try await user.refreshTokensIfNeeded().accessToken.tokenString
///     }
/// }
/// ```
public protocol TokenProvider: Sendable {
    /// Returns a currently valid access token. Throw if the user is not signed in.
    func accessToken() async throws -> String

    /// Called once after a request fails with HTTP 401. Return a fresh token to have the
    /// request retried, or `nil` (the default) to surface the 401 as
    /// ``YouTubeLiveError/unauthorized(_:)``.
    func refreshAccessToken() async throws -> String?
}

public extension TokenProvider {
    func refreshAccessToken() async throws -> String? { nil }
}

/// A token provider that always returns the same token. Useful for tests, scripts and
/// server-side tools that already hold a long-lived token.
public struct StaticTokenProvider: TokenProvider {
    private let token: String

    public init(_ token: String) {
        self.token = token
    }

    public func accessToken() async throws -> String {
        guard !token.isEmpty else { throw YouTubeLiveError.missingAccessToken }
        return token
    }
}

/// A token provider backed by a closure, for apps that already have an `async` token source.
public struct ClosureTokenProvider: TokenProvider {
    private let fetch: @Sendable () async throws -> String
    private let refresh: (@Sendable () async throws -> String?)?

    public init(
        fetch: @escaping @Sendable () async throws -> String,
        refresh: (@Sendable () async throws -> String?)? = nil
    ) {
        self.fetch = fetch
        self.refresh = refresh
    }

    public func accessToken() async throws -> String {
        try await fetch()
    }

    public func refreshAccessToken() async throws -> String? {
        try await refresh?()
    }
}
