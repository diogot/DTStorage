#
#  Be sure to run `pod spec lint DTStorage.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "DTStorage"
  s.version      = "0.0.1"
  s.summary      = "A short description of DTStorage."
  s.description  = <<-DESC
                   A longer description of DTStorage in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC
  s.homepage     = "https://github.com/diogot/DTStorage"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Diogo Tridapalli" => "diogo@diogot.com" }
  s.social_media_url   = "http://twitter.com/diogot"
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/diogot/DTStorage.git", :tag => s.version.to_s }
  s.source_files  = "DTStorage/*.{h,m}"
  s.public_header_files = "DTStorage/DTStorage.h"
  s.framework    = 'SystemConfiguration'
  s.requires_arc = true  
  s.dependency 'FMDB', '~> 2.3'
  s.dependency 'FormatterKit/ArrayFormatter', '~> 1.4.2'
end
