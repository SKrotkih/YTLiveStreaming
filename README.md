# YTLiveStreaming

YTLiveStreaming is an iOS framework which can be used for creating live broadcasts and video streams on YouTube using YouTube Live Streaming API
(YouTube Data API v3)

## Requirements

- Xcode 12+
- Swift 5.0

## Introduction

- First of all enable YouTube LIVE on your account.
- Go to your Google account https://console.developers.google.com
- Create a new application.
- Go to the new application
- Select Library
- Select "YouTube Data API v3"
- Select Credetials
- Create Api key (API_KEY) ; In Key restriction select iOS, enter your iOS app bundle id; Save
- Create Oauth 2.0 Cient ID (CLIENT_ID)

- add three scopes for Google APIs: "https://www.googleapis.com/auth/youtube", "https://www.googleapis.com/auth/youtube.readonly",  "https://www.googleapis.com/auth/youtube.force-ssl"

<img src="https://user-images.githubusercontent.com/2775621/80702066-23271b80-8ae9-11ea-99e8-314ee1ae1c27.png" alt="OAuth consent screen" style="width: 690px;" />

- fill Application Homepage link and Application Privacy Policy link. Submit for verification

- as result you will have API_KEY and CLIENT_ID which will be used in Config.plist your iOS app later.

<img src="https://user-images.githubusercontent.com/2775621/173214138-adc9ca4b-33d6-4781-9f9b-d6ba6038527d.png" alt="Credentials compatible with the Youtube Data API" style="width: 690px;" />

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
platform :ios, '13.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'YTLiveStreaming'
end
```

Then, run the following command:

```bash
$ pod install
```

## Prepare and launch an example

As an example used iOS app Live Events

<img src="https://user-images.githubusercontent.com/2775621/80704225-e826e700-8aec-11ea-875a-7971b76e40da.png" alt="Live Events Logo" style="width: 690px;" />


- Download or clone the repository.

- Select Sample folder

- Launch  `pod install`   

- Open LiveEvents.xcworkspace.

- Change current bundle id on your

- Create Config.plist. Copy content Config.plist.example.plist into new Config.plist. Change current values of the client ID and API key on yours.  

- Put [CLIENT_ID](https://developers.google.com/identity/sign-in/ios/start-integrating#get_an_oauth_client_id) and API_KEY into the plist.info:

<img src="https://user-images.githubusercontent.com/2775621/173193901-cbdc8653-76c8-4aea-b0d9-0f9d4391fba3.png" alt="Config.plist" style="width: 690px;" />

- In Sample/Info.plist edit the CFBundleURLSchemes. Change the value that starts with "com.googleusercontent.apps." based on your API key. It should be set to the reversed API key. The API key has the format XXXXXXXX.apps.googleusercontent.com and the allowed URL should be com.googleusercontent.apps.XXXXXXXX :

<img src="https://user-images.githubusercontent.com/2775621/173220142-003b05e9-3903-4959-b88a-7f1181c1c010.png" alt="Info.plist Example" style="width: 690px;" />

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

	// Get Ready to broadcast events
	input.getUpcomingBroadcasts() { result in
          switch result {
              case .success(let upcomingEvents):
                ...
              case .failure(let error):
                ...
          }    
	} 

	// Get Live now broadcasts
	input.getLiveNowBroadcasts() ( result in
          switch result {
              case .success(let  liveNowEvents):
                  ...
              case .failure(let error):
                  ...
          }
	} 

	// Get Completed broadcasts
	input.getCompletedBroadcasts() ( result in
             switch result {
                 case .success(let completedEvents):
                     ...
                 case .failure(let error):
                     ...
             }
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

- GoogleSignIn
- LFLiveKit (https://github.com/LaiFengiOS/LFLiveKit)
- Alamofire
- SwiftyJSON
- Moya

Note. Here were  used the following things:
- Goggle Sign-In for iOS ( https://developers.google.com/identity/sign-in/ios/start-integrating ) 
- VIPER architect (Clean for iOS) ( https://www.objc.io/issues/13-architecture/viper/ )
- Moya 10
- Alamofire
- RxSwift
- Podspec ( https://guides.cocoapods.org/syntax/podspec.html )
- Swiftlint
- Xcode unit tests
- Objective-C + Swift code example
- SwiftUI used for the sample project

Author
Serhii Krotkykh

The project was created
11-11-2016

Changes history:
14-06-2022
 - update Google Sign-In according actual framework version
18-05-2021
- added SwuftUI based content view for the YouTube video player 
04-05-2021
- added youtube-ios-player-helper as an video player
- added Xcode unit test 
 15-03-2021
- added Swiftlint 
- fixed Swiftlint warnings
- Sample app was renamed to LiveEvents
29-04-2020 
 -  build 0.2.17
 - Sample app was redesigned
 -  GoogleSignIn (used in the Sample app): up to 5.0.2
