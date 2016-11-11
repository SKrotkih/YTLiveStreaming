# YTLiveStreaming

YTLiveStreaming is a framework for creating live broadcasts and video streams on YouTube using the YouTube Live Streaming API
(v.3) in Swift 3 

## Requirements

- Xcode 8
- Swift 3

## Install

First of all accept the Live Streaming in your YouTube account.

Add a new application in your Google account with two thing in the API Manager: API key and OAuth 2.0 client ID.

Add YouTube Data API in the API Library.  

Just one note. When you will create an API key, don't point the iOS apps in the radio box. Don't worry about yellow warning Key restriction. Take the API key and Client ID. They will be used in your Xcode project.

Download or clone the repository.

pod install

Edit Constants.swift:
Replace the following Private parameters on yours:
- GoogleClientID
- APIkey

## Libraries Used

- LFLiveKit (https://github.com/LaiFengiOS/LFLiveKit)
- Alamofire
- AlamofireOauth2
- SwiftyJSON
- Moya

Here is a video how it works: https://youtu.be/HwYbvUU2fJo

11-10-2016
