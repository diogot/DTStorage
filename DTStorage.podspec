Pod::Spec.new do |s|
  s.name         = "DTStorage"
  s.version      = "0.0.1"
  s.summary      = "A simple storage layer over SQLite for iOS."
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
