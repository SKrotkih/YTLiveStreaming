import Foundation

/// Filter for `liveBroadcasts.list` (`broadcastStatus` parameter).
public enum BroadcastListFilter: String, Sendable, CaseIterable {
    /// Current live broadcasts.
    case active
    /// All broadcasts.
    case all
    /// Broadcasts that have already ended.
    case completed
    /// Broadcasts that have not yet started.
    case upcoming
}

/// Target status for `liveBroadcasts.transition`.
public enum BroadcastTransition: String, Sendable, CaseIterable {
    /// Start testing: YouTube transmits video to the broadcast's monitor stream only.
    case testing
    /// Go live: the broadcast becomes visible to its audience.
    case live
    /// End the broadcast: YouTube stops transmitting video.
    case complete
}

/// `status.lifeCycleStatus` of a broadcast. Unknown future values decode as `.unknown`.
public enum LifeCycleStatus: String, Sendable, CaseIterable, LenientCodableEnum {
    case abandoned, complete, created, live, liveStarting, ready, reclaimed, revoked, testStarting, testing
    case unknown
    public static var fallback: LifeCycleStatus { .unknown }
}

/// `status.privacyStatus` of a broadcast.
public enum PrivacyStatus: String, Sendable, CaseIterable, LenientCodableEnum {
    case `public`, `private`, unlisted
    case unknown
    public static var fallback: PrivacyStatus { .unknown }
}

/// `status.streamStatus` of a live stream.
public enum StreamStatus: String, Sendable, CaseIterable, LenientCodableEnum {
    case active, created, error, inactive, ready
    case unknown
    public static var fallback: StreamStatus { .unknown }
}

/// `status.healthStatus.status` of a live stream.
public enum StreamHealth: String, Sendable, CaseIterable, LenientCodableEnum {
    case good, ok, bad, noData
    case unknown
    public static var fallback: StreamHealth { .unknown }
}

/// `cdn.ingestionType` of a live stream.
public enum IngestionType: String, Sendable, CaseIterable, LenientCodableEnum {
    case rtmp, dash, webrtc, hls
    case unknown
    public static var fallback: IngestionType { .unknown }
}

/// `cdn.resolution` of a live stream. Use `.variable` together with `FrameRate.variable`.
public enum StreamResolution: String, Sendable, CaseIterable, LenientCodableEnum {
    case p240 = "240p"
    case p360 = "360p"
    case p480 = "480p"
    case p720 = "720p"
    case p1080 = "1080p"
    case p1440 = "1440p"
    case p2160 = "2160p"
    case variable
    case unknown
    public static var fallback: StreamResolution { .unknown }
}

/// `cdn.frameRate` of a live stream.
public enum FrameRate: String, Sendable, CaseIterable, LenientCodableEnum {
    case fps30 = "30fps"
    case fps60 = "60fps"
    case variable
    case unknown
    public static var fallback: FrameRate { .unknown }
}

/// `contentDetails.latencyPreference` of a broadcast.
public enum LatencyPreference: String, Sendable, CaseIterable, LenientCodableEnum {
    case normal, low, ultraLow
    case unknown
    public static var fallback: LatencyPreference { .unknown }
}

// MARK: - Lenient decoding

/// A `String`-backed enum that decodes unrecognised values as `fallback` instead of failing,
/// so a new value added by YouTube never breaks decoding of the whole resource.
public protocol LenientCodableEnum: RawRepresentable, Codable, Sendable where RawValue == String {
    static var fallback: Self { get }
}

public extension LenientCodableEnum {
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = Self(rawValue: raw) ?? Self.fallback
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
