# YTLiveStreaming

YTLiveStreaming is a framework for creating live broadcasts and video streams on YouTube using the YouTube Live Streaming API
(v.3) in Swift 3 

## Requirements

- Xcode 8
- Swift 3

## Introduction

- First of all enable YouTube LIVE like this: https://switcherstudio.com/en/kb/streaming/how-to-enable-youtube-live 
- Go to your Google account.
- Create a new application.
- Add YouTube Data API in the API Library.  
- Add API key and OAuth 2.0 client ID:

<img src="https://cloud.githubusercontent.com/assets/2775621/20235174/ca7cbf8e-a893-11e6-9753-b148cdec249e.png" alt="Google API Manager" style="width: 690px;" />

Note. When you will create an API key, don't check iOS apps in the radio box. Don't worry about yellow warning Key restriction. Take the API key and Client ID. They will be used on the next step.

## Install

- Download or clone the repository.

- Select root folder 

- Launch  `pod install`

## Prepare and launch the example

- Select Sample folder

- Launch  `pod install`   

- Open YouTubeLiveVideo.xcworkspace.

- Put your Cliend ID and API key into plist.info:

<img src="https://cloud.githubusercontent.com/assets/2775621/20235407/9d4de014-a899-11e6-825b-fb46a4da49fe.png" alt="Credentials" style="width: 690px;" />

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
- AlamofireOauth2
- SwiftyJSON
- Moya




11-11-2016
