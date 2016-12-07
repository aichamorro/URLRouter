#
# Be sure to run `pod lib lint HudlHttpClient.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "URLRouter"
  s.version          = "1.1.0"
  s.summary          = "With URLRouter you can assign actions to URL patterns"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = "With URLRouter assignign actions to URL patterns is very simple. Besides, it can parse path and URL parameters."

  s.homepage         = "https://github.com/aichamorro/URLRouter/"
  s.license          = 'MIT'
  s.author           = { "Alberto Chamorro" => "aichamorro.dev@gmail.com" }
  s.source           = { :git => "https://github.com/aichamorro/URLRouter.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/aichamorro'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.requires_arc = true

  s.source_files = 'URLRouter/**/*.{swift,h}' 
end
