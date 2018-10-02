# YTLiveStreaming

YTLiveStreaming is a framework for creating live broadcasts and video streams on YouTube using the YouTube Live Streaming API
(YouTube Data API v3) in Swift 4

## Requirements

- Xcode 10.0
- Swift 4.2

## Introduction

- First of all enable YouTube LIVE on your account.
- Go to your Google account https://console.developers.google.com
- Create a new application.
- Go to the new application
- Select Library
- Select "YouTube Data API v3"
- Create Api key (API_KEY) ; In Key restriction select iOS, enter your iOS app bundle id; Save
- Create Oauth Cient ID
- Add API key and OAuth 2.0 client ID:

<img src="https://user-images.githubusercontent.com/2775621/36204190-e80344a6-1192-11e8-9431-e18ad4bff9a3.png" alt="Google API Manager" style="width: 690px;" />

Note. When you will create an API key, don't check iOS apps in the radio box. Don't worry about yellow warning Key restriction. Take the API key and Client ID. They will be used on the next step.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build YTLiveStreaming

To integrate YTLiveStreaming into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'YTLiveStreaming'
end
```

Then, run the following command:

```bash
$ pod install
```

## Prepare and launch the example

- Download or clone the repository.

- Select Sample folder

- Launch  `pod install`   

- Open YouTubeLiveVideo.xcworkspace.

- Put your CLIENT_ID and API_KEY into the plist.info:

<img src="https://user-images.githubusercontent.com/2775621/36204258-42684ab8-1193-11e8-88c4-a7668f7de368.png" alt="Credentials" style="width: 690px;" />

## User guide

	import YTLiveStreaming

	...

	let input: YTLiveStreaming = YTLiveStreaming

	...

	// Get all events in different arrays of the LiveBroadcastStreamModel type 
	input.getAllBroadcasts(){ (upcomingEvents, liveNowEvents, completedEvents) in
	   ...
	}

	// Get events separately:
	// Get upcoming events
	input.getUpcomingBroadcasts() { upcomingEvents in
	   ...
	} 

	// Get Live now events
	input.getLiveNowBroadcasts() ( liveNowEvents in
	   ...
	} 

	// Get Completed events
	input.getCompletedBroadcasts() ( completedEvents in
	   ...
	} 

	// Create Broadcast
	input.createBroadcast(title, description: description, startTime: startDate, completion: { liveBroadcast in
	   if let liveBroadcast = liveBroadcast {
	      ...
	   }
	})

	// Update of the existing broadcast: LiveBroadcastStreamModel
	input.updateBroadcast(broadcast, completion: { success in
	    if success {
	       ...
	    }      
	})

	// Start broadcast streaming video
	input.startBroadcast(broadcast, delegate: self, completion: { streamName, streamUrl, _ in
	   if let streamName = streamName, let streamUrl = streamUrl {
	     completion(streamUrl, streamName)
	   }
	})

	// Finish broadcast streaming video
	input.completeBroadcast(broadcast, completion: { success in
	   if success {
	      ...
	   }
	})

	// Delete broadcast video from YouTube
	input.deleteBroadcast(id: broadcastId, completion: { success in
	    if success {
	       ...
	    }
	})
	

And some other public methods of the YTLiveStreaming class  

## Libraries Used

- LFLiveKit (https://github.com/LaiFengiOS/LFLiveKit)
- Alamofire
- SwiftyJSON
- Moya

Note. Here I used the following things:
- Goggle Sign-In for iOS ( https://developers.google.com/identity/sign-in/ios/ )
- VIPER architect (Clean for iOS) ( https://www.objc.io/issues/13-architecture/viper/ )
- Moya 10
- Alamofire
- Podspec ( https://guides.cocoapods.org/syntax/podspec.html )

Sergey Krotkih

11-11-2016

Updated 10-02-2018

