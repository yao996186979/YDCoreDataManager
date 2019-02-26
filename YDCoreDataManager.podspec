Pod::Spec.new do |s|

  s.name         = "YDCoreDataManager"
  s.version      = "0.0.1"  
  s.summary      = "Easy to use CoreData."
  s.description  = <<-DESC
                   It is a tool for coreData to operation,written by Objective-C.
                   DESC
  s.homepage     = "https://github.com/yao996186979/YDCoreDataManager.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = {"yaodong" => "1248170343@qq.com"}
  s.source       = { :git => "https://github.com/yao996186979/YDCoreDataManager.git", :tag => "0.0.1" }
  s.source_files  ="YDCoreDataManager","*.{h,m}"
  s.requires_arc = true
  s.framework  = "UIKit"
  s.ios.deployment_target = '8.0'
end
