Pod::Spec.new do |s|

  s.platform     = :ios
  s.ios.deployment_target = '9.0'
  s.name         = "YTLiveStreaming"
  s.description  = <<-DESC
     YTLiveStreaming is a framework which lets create live broadcasts and video streams on YouTube using the YouTube Live Streaming API.
                   DESC
  s.summary      = "YTLiveStreaming is a YouTube Live Streaming Framework"
  s.requires_arc = true

  s.version      = "0.2.7"

  # Initialize
  # Check podspec
  # pod lib lint YTLiveStreaming.podspec
  # First commit
  # git commit -m "Initial Commit"
  # git remote add origin https://github.com/SKrotkih/YTLiveStreaming.git
  # git push -u origin master

  # Make for new version:
  # 1. git tag 0.2.7
  # 2. git push -u origin master --tags
  # 3. pod spec lint YTLiveStreaming.podspec --allow-warnings --swift-version=4.0
  # Push podspec with the new version info
  # Create session:
  # 4. pod trunk register sergey.krotkih@gmail.com "Sergey Krotkih" --description="CocoaPods Session for the YTLiveStreaming"
  # 5. pod trunk push YTLiveStreaming.podspec --verbose --allow-warnings --swift-version=4.0

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Sergey Krotkih" => "sergey.krotkih@gmail.com" }
  s.homepage     = "https://github.com/SKrotkih/YTLiveStreaming.git"

  s.source       = { :git => "https://github.com/SKrotkih/YTLiveStreaming.git", :tag => s.version.to_s }

  s.frameworks   = "UIKit"
  s.dependency 'Moya', '10.0.0'
  s.dependency 'LFLiveKit'
  s.dependency 'SwiftyJSON'
  s.dependency 'KeychainAccess'

  s.source_files = "YTLiveStreaming/**/*.{swift,h,m}"

  s.public_header_files = ['YTLiveStreaming/YTLiveStreaming.h']

end
