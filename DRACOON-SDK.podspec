#
# Be sure to run `pod lib lint DRACOON-Crypto-SDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DRACOON-SDK'
  s.version          = '2.2.0'
  s.summary          = 'Official DRACOON SDK'

  s.description      = <<-DESC
  This SDK implements access to DRACOON API.
                       DESC

  s.homepage         = 'https://github.com/dracoon/dracoon-swift-sdk'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Mathias Schreiner' => 'm.schreiner@dracoon.com' }
  s.source           = { :git => 'https://github.com/dracoon/dracoon-swift-sdk.git', :tag => "v" + s.version.to_s }
  s.module_name      = 'dracoon_sdk'

  s.ios.deployment_target = '11.4'
  s.swift_version = '5.3'

  s.source_files = 'dracoon-sdk/**/*'

   s.dependency 'Alamofire', '~> 5.4.0'
   s.dependency 'DRACOON-Crypto-SDK', '~> 2.1.0'
end
