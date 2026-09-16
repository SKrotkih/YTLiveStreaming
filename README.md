# YTLiveStreaming

[![CI](https://github.com/SKrotkih/YTLiveStreaming/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/SKrotkih/YTLiveStreaming/actions/workflows/ci.yml)
[![Swift Package Index](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSKrotkih%2FYTLiveStreaming%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/SKrotkih/YTLiveStreaming)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSKrotkih%2FYTLiveStreaming%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/SKrotkih/YTLiveStreaming)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)

A dependency-free Swift client for the **YouTube Live Streaming API** (the `liveBroadcasts` and
`liveStreams` resources of YouTube Data API v3). Create, schedule, bind, start and end live
broadcasts on YouTube from iOS, macOS, tvOS, watchOS or visionOS apps.

> **1.0 is a rewrite.** The 0.2.x line (Moya / Alamofire / SwiftyJSON, callback API) is tagged
> [`legacy-0.2.45`](https://github.com/SKrotkih/YTLiveStreaming/tree/legacy-0.2.45) and is no longer
> maintained. See [Migrating from 0.2.x](#migrating-from-02x).

- Swift 5.9+, strict concurrency clean; `async/await` only
- Zero third-party dependencies (`URLSession` + `Codable`)
- iOS 15 / macOS 12 / tvOS 15 / watchOS 8 / visionOS 1
- You own sign-in: plug in any OAuth token source via one protocol

## Installation

Swift Package Manager only:

```swift
.package(url: "https://github.com/SKrotkih/YTLiveStreaming.git", from: "1.1.0")
```

## Google Cloud setup

1. Enable **live streaming** on the YouTube channel (YouTube Studio → Go live; first-time
   activation takes up to 24 h).
2. In [Google Cloud Console](https://console.cloud.google.com) create a project, enable
   **YouTube Data API v3**, and create an **OAuth 2.0 Client ID** for iOS.
3. Request these scopes when signing in:
   `https://www.googleapis.com/auth/youtube`
   `https://www.googleapis.com/auth/youtube.force-ssl`
   (`youtube.readonly` is enough for list calls only.)

An API key is optional — requests are authorised by the OAuth bearer token. If you do pass one
and it is restricted to iOS apps, also pass your bundle identifier (the default).

## Usage

### 1. Provide a token

The library never performs sign-in. Implement `TokenProvider` on top of whatever you use
(GoogleSignIn SDK, AppAuth, your backend):

```swift
import GoogleSignIn
import YTLiveStreaming

struct GoogleSignInTokenProvider: TokenProvider {
    func accessToken() async throws -> String {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            throw YouTubeLiveError.missingAccessToken
        }
        return try await user.refreshTokensIfNeeded().accessToken.tokenString
    }
}

let youtube = YouTubeLiveClient(tokenProvider: GoogleSignInTokenProvider())
```

`StaticTokenProvider("…")` and `ClosureTokenProvider(fetch:refresh:)` are included for scripts and
tests. If `refreshAccessToken()` returns a token, a request that failed with 401 is retried once.

### 2. Broadcasts

```swift
// List
let upcoming = try await youtube.allBroadcasts(.upcoming)        // every page, newest first
let page     = try await youtube.broadcasts(.completed)          // one page + nextPageToken
let one      = try await youtube.broadcast(id: "VIDEO_ID")

// Create broadcast + stream and bind them in one go
let (broadcast, stream) = try await youtube.createBroadcastWithStream(
    CreateBroadcastRequest(
        title: "Sunday service",
        description: "Live from the hall",
        scheduledStartTime: .now.addingTimeInterval(3600),
        privacyStatus: .unlisted,
        enableAutoStart: true,
        enableAutoStop: true
    ),
    stream: CreateStreamRequest(title: "Main camera")
)

// Point your RTMP encoder here:
let ingest = stream.cdn?.ingestionInfo
print(ingest?.ingestionAddress ?? "", ingest?.streamName ?? "")   // or ingest?.fullIngestionURL

// Update
var edited = broadcast
edited.snippet.title = "Sunday service (rescheduled)"
edited.snippet.scheduledStartTime = .now.addingTimeInterval(7200)
try await youtube.updateBroadcast(edited)

// Go live / end (the encoder must already be sending data before .testing / .live)
try await youtube.transition(broadcastID: broadcast.id, to: .live)
try await youtube.transition(broadcastID: broadcast.id, to: .complete)

// Delete
try await youtube.deleteBroadcast(id: broadcast.id)
try await youtube.deleteBroadcasts(ids: upcoming.map(\.id))
```

### 3. Streams

```swift
let stream  = try await youtube.stream(id: "STREAM_ID")
let mine    = try await youtube.streams()
let created = try await youtube.createStream(.init(title: "Cam 2", resolution: .p1080, frameRate: .fps60))
try await youtube.bind(broadcastID: broadcast.id, streamID: created.id)
try await youtube.deleteStream(id: created.id)

if stream.isReceivingData && stream.health == .good { /* safe to transition to .live */ }
```

### 4. Going live

Start your encoder against the stream's ingestion URL, then either observe the broadcast:

```swift
for try await event in youtube.monitor(broadcastID: broadcast.id) {
    switch event {
    case .snapshot(let s):       status = "\(s.lifeCycleStatus) · encoder \(s.streamStatus) · \(s.streamHealth)"
    case .encoderConnected:      // YouTube is receiving data
    case .transitionRequested:   // monitor is moving the broadcast towards .live
    case .transitionFailed(_, let error): log(error)   // e.g. errorStreamInactive; it retries
    case .testing:               // preview available in YouTube Studio
    case .live:                  onAir = true
    case .pollFailed(let error): log(error)            // transient; polling continues
    case .ended(let state):      onAir = false          // .complete / .revoked / .abandoned
    }
}
```

…or just wait for it:

```swift
let live = try await youtube.goLive(broadcastID: broadcast.id, timeout: 120)
```

The monitor polls every 3 s by default (`MonitorOptions(pollInterval:)`), follows YouTube's rules
(`ready → testing → live` when the monitor stream is enabled, `ready → live` otherwise), and stops
when the broadcast ends or the consuming task is cancelled. Pass `autoGoLive: false` to only
observe, e.g. for broadcasts created with `enableAutoStart`.

### 5. Live chat, ad breaks, thumbnails

```swift
// Chat: liveChatId comes from the broadcast
if let chatId = broadcast.snippet.liveChatId {
    for try await batch in youtube.chatMessageStream(liveChatId: chatId) {   // polls at YouTube's interval
        for message in batch { print(message.authorName, message.text) }
    }
    try await youtube.sendChatMessage("Welcome!", liveChatId: chatId)
}

// Ad break (channel must have ads enabled)
try await youtube.insertCuepoint(broadcastID: broadcast.id, CuepointRequest(durationSeconds: 60))

// Custom thumbnail (JPEG/PNG, ≤ 2 MB)
try await youtube.setThumbnail(broadcastID: broadcast.id, imageData: jpegData)
```

Decoding fixtures or cached JSON into the models: `JSONDecoder.youtubeLive()`.

### 6. Errors

Everything throws `YouTubeLiveError`:

```swift
do {
    try await youtube.transition(broadcastID: id, to: .live)
} catch YouTubeLiveError.forbidden(let api) where api?.reason == "errorStreamInactive" {
    // encoder is not sending yet
} catch YouTubeLiveError.unauthorized {
    // sign the user in again
} catch let error as YouTubeLiveError {
    print(error.localizedDescription, error.apiError?.reason ?? "")
}
```

### Testing your own code

Inject an `HTTPTransport` instead of `URLSession.shared` to answer requests from fixtures — see
`Tests/YTLiveStreamingTests/TestSupport.swift` for a ready-made recording mock.

## Documentation

The package ships a DocC catalog: in Xcode choose **Product ▸ Build Documentation** (⌃⇧⌘D) with the
`YTLiveStreaming` scheme, or run `swift package generate-documentation` with the
[swift-docc-plugin](https://github.com/apple/swift-docc-plugin).

## Migrating from 0.2.x

| 0.2.x | 1.0 |
|---|---|
| `YTLiveStreaming()` singleton-style object | `YouTubeLiveClient(tokenProvider:)` |
| `GoogleOAuth2.sharedInstance.accessToken = …` | implement `TokenProvider` |
| `API_KEY` / `CLIENT_ID` in `Info.plist` | `Configuration(apiKey:)` (optional) |
| `getUpcomingBroadcasts { result in … }` | `try await client.allBroadcasts(.upcoming)` |
| `createBroadcast(PostLiveBroadcastBody)` | `createBroadcastWithStream(CreateBroadcastRequest, stream:)` |
| `startBroadcast(_:delegate:)` + `LiveStreamTransitioning` delegate | `for try await event in client.monitor(broadcastID:)` or `try await client.goLive(broadcastID:)` |
| `completeBroadcast(_:)` | `transition(broadcastID:to: .complete)` |
| `LiveBroadcastStreamModel.status?.lifeCycleStatus: String` | `LifeCycleStatus` enum (`.live`, `.ready`, …, `.unknown`) |
| `LiveStreamModel.snipped` | `LiveStreamModel.snippet` |
| CocoaPods | SPM only |

## Example app

[LiveEvents](https://github.com/SKrotkih/LiveEvents) — will be updated for 1.0.

## License

MIT — see [LICENSE](LICENSE).
