Pod::Spec.new do |s|

s.name         = "YTLiveStreaming"
s.version      = "0.1.1"

# TODO
# git tag 0.1.1
# git push -u origin master --tags
#
# pod repo add YTLiveStreamingPodSpecs https://github.com/SKrotkih/YTLiveStreamingPodSpecs.git
# pod repo push YTLiveStreamingPodSpecs YTLiveStreaming.podspec

s.summary      = "YouTube Live Streaming Framework"
s.description  = <<-DESC

* Create live broadcasts and video streams on YouTube using the YouTube Live Streaming API.
DESC

s.homepage     = "https://github.com/SKrotkih/YTLiveStreaming.git"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = { "Sergey Krotkih" => "sergey.krotkih@gmail.com" }
s.platform     = :ios, "9.0"
s.ios.deployment_target = "9.0"
s.source       = { :git => "https://github.com/SKrotkih/YTLiveStreaming.git", :tag => "#{s.version}" }
s.source_files = "YTLiveStreaming", "YTLiveStreaming/**/*.{h,m,swift}"
s.frameworks = "Foundation","UIKit"
s.requires_arc = true
s.dependency 'AlamofireOauth2'
s.dependency 'KeychainAccess'
s.dependency 'XCGLogger'
s.dependency 'LFLiveKit'
s.dependency 'SwiftyJSON'
s.dependency 'Moya', '8.0.0-beta.2'
s.dependency 'XCDYouTubeKit', '~> 2.5'
s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3' }

end
