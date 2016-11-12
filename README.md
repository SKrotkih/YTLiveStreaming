# YTLiveStreaming

[![Swift 3](https://img.shields.io/badge/Swift-3-orange.svg?style=flat)](https://swift.org/)

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

- Select Sample folder.

- Launch  `pod install`   

- Open YouTubeLiveVideo.xcworkspace.

- Put your Cliend ID and API key into plist.info:

<img src="https://cloud.githubusercontent.com/assets/2775621/20235407/9d4de014-a899-11e6-825b-fb46a4da49fe.png" alt="Credentials" style="width: 690px;" />

## User guide




## Libraries Used

- LFLiveKit (https://github.com/LaiFengiOS/LFLiveKit)
- Alamofire
- AlamofireOauth2
- SwiftyJSON
- Moya




11-11-2016
