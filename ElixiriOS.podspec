#
# Be sure to run `pod lib lint ElixiriOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ElixiriOS'
  s.version          = '0.1.0'
  s.summary          = 'Elixir makes it easier to define and manage your conversion values for SKADNetwork'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Elixir is a tool created by 2ndPotion. It makes it easier to define and manage your conversion values in the server side. Elixir will take care of identifying the conversion value that should be sent at any time'

  s.homepage         = 'https://github.com/2ndpotion/ElixiriOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kevin@2ndpotion.com' => 'kevin@2ndpotion.com' }
  s.source           = { :git => 'https://github.com/2ndpotion/ElixiriOS.git', :tag => s.version.to_s }
   s.social_media_url = 'https://twitter.com/kevin_brv'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ElixiriOS/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ElixiriOS' => ['ElixiriOS/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
