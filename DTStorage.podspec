Pod::Spec.new do |s|
  s.name         = "DTStorage"
  s.version      = "0.1.0"
  s.summary      = "A library for data persistence on iOS that uses SQLite (with FMDB)."
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

# TODO: source_files in a global scope

  s.subspec 'standard' do |ss|
    ss.source_files = "DTStorage/*.{h,m}"
    ss.dependency 'FMDB'
  end
  
  s.subspec 'SQLCipher' do |ss|
    ss.source_files = "DTStorage/*.{h,m}"
    ss.dependency 'FMDB/SQLCipher'
  end

end
