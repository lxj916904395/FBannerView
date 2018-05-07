Pod::Spec.new do |s|
  s.name         = "FBannerView"
  s.version      = "1.0.0"
  s.summary      = "A view for AD show"
  s.description  = "A view for AD show addtion with cocoapod support."
  s.homepage     = "https://github.com/lxj916904395/FBannerView"
  s.license= "MIT"
  s.author       = { "lxj916904395" => "916904395@qq.com" }
  s.source       = { :git => "https://github.com/lxj916904395/FBannerView.git", :tag => s.version.to_s }
  s.source_files = 'FBannerView/FBannerView/*.{h,m}'
  s.ios.deployment_target = '6.0'
  s.frameworks   = 'UIKit'
  s.requires_arc = true

end
