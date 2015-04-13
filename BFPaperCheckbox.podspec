
Pod::Spec.new do |s|
  s.name         = "BFPaperCheckbox"
  s.version      = "1.2.6"
  s.summary      = "iOS Checkboxes inspired by Google's Paper Material Design."
  s.homepage     = "https://github.com/bfeher/BFPaperCheckbox"
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = { "Bence Feher" => "ben.feher@gmail.com" }
  s.source       = { :git => "https://github.com/bfeher/BFPaperCheckbox.git", :tag => "1.2.6" }
  s.platform     = :ios, '7.0'
  s.dependency   'UIColor+BFPaperColors'
 
  
  s.source_files = 'Classes/*.{h,m}'
  s.requires_arc = true

end
