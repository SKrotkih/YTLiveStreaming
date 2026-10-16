import Foundation

// MARK: - Channel

public extension YouTubeLiveClient {
    /// The signed-in account's channel (`channels.list?mine=true`, 1 quota unit), or `nil` when
    /// the Google account has no YouTube channel yet.
    ///
    /// A Google account without a channel signs in fine, but every live-streaming call then
    /// fails with 401 `youtubeSignupRequired` — which looks like an expired sign-in. Call this
    /// right after sign-in and send such users to create a channel instead
    /// (``YouTubeLiveClient/createChannelURL``). The API cannot create a channel on their behalf.
    ///
    /// ```swift
    /// guard let channel = try await youtube.myChannel() else {
    ///     showCreateChannel(YouTubeLiveClient.createChannelURL)
    ///     return
    /// }
    /// print("Signed in as", channel.snippet?.title ?? channel.id)
    /// ```
    func myChannel() async throws -> ChannelModel? {
        do {
            let list: ChannelListModel = try await perform(Endpoint(
                method: .get,
                path: "channels",
                query: [Endpoint.part(Parts.channel), URLQueryItem(name: "mine", value: "true")]
            ))
            return list.items?.first
        } catch let error as YouTubeLiveError where error.isSignupRequired {
            return nil
        }
    }

    /// YouTube's page where the signed-in user creates a channel. Open it in a browser
    /// (the user picks the name and accepts YouTube's terms there), then call ``myChannel()`` again.
    static let createChannelURL = URL(string: "https://www.youtube.com/create_channel")!
}
