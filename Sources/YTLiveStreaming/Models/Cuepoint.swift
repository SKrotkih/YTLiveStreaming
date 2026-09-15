import Foundation

/// A `cuepoint` resource — an ad break inserted into a live broadcast.
///
/// Docs: https://developers.google.com/youtube/v3/live/docs/liveBroadcasts/cuepoint
/// Requires a channel with ads enabled; otherwise YouTube answers 403.
public struct Cuepoint: Codable, Sendable, Equatable {
    public let id: String?
    public let cueType: String?
    public let durationSecs: Int?
    /// Unix ms at which the cuepoint is (or was) inserted; a string in Google's JSON.
    public let walltimeMs: String?
    public let insertionOffsetTimeMs: String?
    public let etag: String?
}

/// Parameters for `liveBroadcasts.cuepoint`.
public struct CuepointRequest: Sendable, Equatable {
    /// Ad break length, 30–120 s (YouTube default 30).
    public var durationSeconds: Int
    /// When to insert. `nil` = now.
    public var walltime: Date?
    /// Offset from the broadcast start, in ms. Mutually exclusive with `walltime`.
    public var insertionOffsetTimeMs: Int?

    public init(durationSeconds: Int = 30, walltime: Date? = nil, insertionOffsetTimeMs: Int? = nil) {
        self.durationSeconds = durationSeconds
        self.walltime = walltime
        self.insertionOffsetTimeMs = insertionOffsetTimeMs
    }
}

struct InsertCuepointBody: Encodable {
    let cueType = "cueTypeAd"
    let durationSecs: Int
    let walltimeMs: Int64?
    let insertionOffsetTimeMs: Int?

    init(_ request: CuepointRequest) {
        durationSecs = request.durationSeconds
        walltimeMs = request.walltime.map { Int64($0.timeIntervalSince1970 * 1000) }
        insertionOffsetTimeMs = request.insertionOffsetTimeMs
    }
}
