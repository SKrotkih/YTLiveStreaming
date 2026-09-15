import Foundation

/// JSON coders configured for the YouTube Data API.
///
/// Dates come back as RFC 3339 with or without fractional seconds
/// (`2024-05-29T10:28:10.000Z`, `2024-05-29T10:28:10Z`); we accept both and always emit
/// the fractional form.
enum JSONCoding {
    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = RFC3339.date(from: raw) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected an RFC 3339 date, got \"\(raw)\""
            )
        }
        return decoder
    }

    static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(RFC3339.string(from: date))
        }
        return encoder
    }

    static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try makeDecoder().decode(T.self, from: data)
        } catch {
            throw YouTubeLiveError.decoding(underlying: error, body: data)
        }
    }

    static func encode<T: Encodable>(_ value: T) throws -> Data {
        try makeEncoder().encode(value)
    }
}

/// RFC 3339 / ISO 8601 helpers. `ISO8601DateFormatter` is not `Sendable` on older SDKs, so
/// instances are created per call rather than cached in a global.
public enum RFC3339 {
    public static func date(from string: String) -> Date? {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractional.date(from: string) { return date }
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        return plain.date(from: string)
    }

    public static func string(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}

public extension JSONDecoder {
    /// A decoder configured for YouTube Data API payloads (RFC 3339 dates with or without
    /// fractional seconds). Use it to decode fixtures or cached responses into the library's models.
    static func youtubeLive() -> JSONDecoder { JSONCoding.makeDecoder() }
}

public extension JSONEncoder {
    /// An encoder configured for YouTube Data API payloads (RFC 3339 dates with fractional seconds).
    static func youtubeLive() -> JSONEncoder { JSONCoding.makeEncoder() }
}
