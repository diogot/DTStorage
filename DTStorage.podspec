Pod::Spec.new do |s|
  s.name         = "DTStorage"
  s.version      = "0.0.2"
  s.summary      = "A simple storage layer over SQLite for iOS."
  s.homepage     = "https://github.com/diogot/DTStorage"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Diogo Tridapalli" => "diogo@diogot.com" }
  s.social_media_url   = "http://twitter.com/diogot"
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/diogot/DTStorage.git", 
                     :tag => s.version.to_s }
  s.framework    = 'SystemConfiguration'
  s.requires_arc = true
  
  s.default_subspec = 'standard'

  s.subspec 'common' do |ss|
    ss.source_files = "DTStorage/*.{h,m}"
    ss.private_header_files = "DTStorage/*_Private.h"    
    ss.dependency 'FormatterKit/ArrayFormatter'
  end

  s.subspec 'standard' do |ss|
    ss.dependency 'DTStorage/common'
    ss.dependency 'FMDB'
  end

  s.subspec 'SQLCipher' do |ss|
    ss.dependency 'DTStorage/common'
    ss.dependency 'FMDB/SQLCipher'
  end

end
