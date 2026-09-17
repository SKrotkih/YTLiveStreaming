# Changelog

## 1.1.2 — 2026-09-17

### Fixed
- `monitor(broadcastID:)` no longer ends with `.notFound` when a just-created broadcast is not yet
  visible to `liveBroadcasts.list`: a 404 inside `MonitorOptions.notFoundGracePeriod` (default 90 s)
  is reported as `.pollFailed` and polling continues. Set it to `0` for the old behaviour.
- `allBroadcasts(_:)` drops duplicate IDs when YouTube pages overlap (the channel changing between
  page requests) — duplicates crashed SwiftUI `List` diffing in clients.

## 1.1.1 — 2026-09-16

### Added
- `purgeBroadcast(id:deleteBoundStream:)` / `purgeBroadcasts(ids:)`: delete a broadcast without
  leaving traces — ends a running one first, falls back to `videos.delete` when
  `liveBroadcasts.delete` refuses a completed broadcast, removes the recording and the bound
  `liveStream` (unless reusable). `PurgeResult` reports what was done.
- `deleteVideo(id:)` (`videos.delete`).

## 1.1.0 — 2026-09-15

### Added
- **Live chat**: `chatMessages(liveChatId:pageToken:)`, `chatMessageStream(liveChatId:)` (an
  `AsyncThrowingStream` that polls at the interval YouTube requests and ends when the chat goes
  offline), `sendChatMessage(_:liveChatId:)`, `deleteChatMessage(id:)`; `LiveChatMessage` model with
  text, Super Chat, Super Sticker, membership and moderation event types.
- **Ad breaks**: `insertCuepoint(broadcastID:_:)` (`liveBroadcasts.cuepoint`).
- **Thumbnails**: `setThumbnail(broadcastID:imageData:contentType:)` (`thumbnails.set`, media upload).
- `JSONDecoder.youtubeLive()` / `JSONEncoder.youtubeLive()` — the library's coders (RFC 3339 dates)
  for decoding fixtures or cached responses into the models.

### Verified
- 1.0 `monitor(broadcastID:)` confirmed end-to-end on a physical iPhone with the LiveEvents sample:
  `ready → testing → live → complete` against a real channel.

## 1.0.0 — 2026-09-15

A from-scratch rewrite. The 0.2.x line is preserved under the `legacy-0.2.45` tag and is no longer maintained.

### Highlights
- **Zero dependencies.** Moya, Alamofire, SwiftyJSON, KeychainAccess and CocoaPods are gone; the client is `URLSession` + `Codable`.
- **`async/await` only**, strict-concurrency clean. `YouTubeLiveClient` is `Sendable` and can be shared across the app.
- **You own sign-in.** Implement `TokenProvider` on top of GoogleSignIn / AppAuth / your backend; the library never touches credentials, `Info.plist` or the Keychain. A request that fails with 401 is retried once with a refreshed token.
- **`monitor(broadcastID:)`** — an `AsyncThrowingStream<BroadcastEvent>` that watches a broadcast and its bound stream and takes it live (`ready → testing → live`, or `ready → live` when the monitor stream is off) once the encoder is sending. **`goLive(broadcastID:timeout:)`** wraps it for the common case. Replaces `LiveLauncher` and the `LiveStreamTransitioning` delegate.
- **Typed errors.** `YouTubeLiveError` carries Google's error payload (`apiError?.reason`, e.g. `errorStreamInactive`, `liveStreamingNotEnabled`) instead of a generic string.
- **Lenient models.** Unknown enum values decode as `.unknown`; optional fields are optional, so a partial resource never breaks decoding.
- Platforms: iOS 15, macOS 12, tvOS 15, watchOS 8, visionOS 1. Swift tools 5.9.
- CI on GitHub Actions: SPM build/test on macOS, `xcodebuild test` on an iOS simulator, builds for tvOS / watchOS / visionOS.

### Fixed (carried over from 0.2.x reports)
- Broadcast description was sent to the stream but not the broadcast, leaving the video description blank (#17).
- `contentDetails.latencyPreference` was modelled as `Bool`; it is a string enum (`normal` / `low` / `ultraLow`) (#20).
- `liveBroadcasts.update` nested `status` and `contentDetails` inside `snippet`, which YouTube ignores.
- `boundStreamLastUpdateTimeMs` is a date, not an integer.
- Update requests no longer echo read-only fields.
- Generic "Something went wrong with creating a broadcast" replaced by the actual API error (#7, #10).

### Breaking changes
See the migration table in [README.md](README.md#migrating-from-02x). In short:
`YTLiveStreaming` → `YouTubeLiveClient(tokenProvider:)`; `GoogleOAuth2` / `Info.plist` keys → `TokenProvider`;
callbacks → `async throws`; `startBroadcast(_:delegate:)` → `monitor(broadcastID:)` / `goLive(broadcastID:)`;
`LiveStreamModel.snipped` → `snippet`; lifecycle / privacy / stream statuses are enums; CocoaPods dropped.

## 0.2.45 and earlier
See git history up to the `legacy-0.2.45` tag.
