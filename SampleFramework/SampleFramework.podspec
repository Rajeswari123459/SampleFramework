Pod::Spec.new do |spec|
  spec.name         = "SampleFramework"
  spec.version      = "1.0.0"
  spec.summary      = "This is use of camera functions."
  spec.description  = "This is use of scanning and camera functions."
  spec.homepage     = "https://github.com/Rajeswari123459/SampleFramework"
  spec.license      = "MIT"
  spec.author             = { "Rajeswari" => "rajeswari.natesan@bank-genie.com" }
  spec.platform     = :ios, "14.1"
  spec.source       = { :git => "https://github.com/Rajeswari123459/SampleFramework.git", :tag => spec.version.to_s }
  spec.source_files  = "SampleFramework", "SampleFramework/**/*.{swift,h,m}"
  spec.swift_versions = "5.0"
    
end
