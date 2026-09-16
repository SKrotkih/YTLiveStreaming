# ``YTLiveStreaming``

Create, schedule, bind and drive YouTube live broadcasts from Swift, with `async/await` and no third-party dependencies.

## Overview

`YTLiveStreaming` wraps the [YouTube Live Streaming API](https://developers.google.com/youtube/v3/live/docs)
(`liveBroadcasts`, `liveStreams`, `liveChatMessages`, cuepoints, thumbnails) in a `Sendable`
``YouTubeLiveClient`` built on `URLSession` and `Codable`.

The library does **not** sign the user in. Your app owns Google Sign-In (any SDK) and hands the
OAuth access token to the client through the ``TokenProvider`` protocol; a `401` is retried once
with the token returned by ``TokenProvider/refreshAccessToken()``.

```swift
struct MyTokens: TokenProvider {
    func accessToken() async throws -> String { /* from your sign-in SDK */ }
}

let youtube = YouTubeLiveClient(tokenProvider: MyTokens())
let upcoming = try await youtube.broadcasts(.upcoming)
```

### Going live

Create a broadcast with its stream, point your RTMP encoder at the ingestion URL, then let
``YouTubeLiveClient/monitor(broadcastID:options:)`` walk the broadcast through
`ready → testing → live` as soon as the encoder is sending:

```swift
let (broadcast, stream) = try await youtube.createBroadcastWithStream(
    CreateBroadcastRequest(title: "My show", scheduledStartTime: .now),
    stream: CreateStreamRequest(title: "My encoder")
)
if let url = stream.cdn?.ingestionInfo?.fullIngestionURL {
    encoder.start(url: url)
}

for try await event in youtube.monitor(broadcastID: broadcast.id) {
    switch event {
    case .live:            print("● LIVE")
    case .ended(let why):  print("ended: \(why)")
    default:               break
    }
}
```

``YouTubeLiveClient/goLive(broadcastID:timeout:pollInterval:)`` is the one-call version.

## Topics

### Essentials

- ``YouTubeLiveClient``
- ``YouTubeLiveClient/Configuration``
- ``TokenProvider``
- ``StaticTokenProvider``
- ``ClosureTokenProvider``
- ``YouTubeLiveError``
- ``GoogleAPIError``

### Broadcasts

- ``LiveBroadcastStreamModel``
- ``CreateBroadcastRequest``
- ``BroadcastListFilter``
- ``BroadcastTransition``
- ``LifeCycleStatus``
- ``PurgeResult``

### Streams

- ``LiveStreamModel``
- ``CreateStreamRequest``
- ``StreamStatus``
- ``StreamHealth``

### Monitoring a broadcast

- ``BroadcastEvent``
- ``BroadcastSnapshot``
- ``MonitorOptions``

### Live chat, cuepoints, thumbnails

- ``LiveChatMessage``
- ``LiveChatMessageListModel``
- ``CuepointRequest``
- ``Cuepoint``
- ``ThumbnailSetResponse``

### Networking

- ``HTTPTransport``
- ``JSONDecoder/youtubeLive()``
- ``JSONEncoder/youtubeLive()``
