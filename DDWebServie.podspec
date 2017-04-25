Pod::Spec.new do |s|  
  s.name             = "DDWebServie"  
  s.version          = "1.0.0"  
  s.summary          = "A WebServie with AFNetWorking"  
  s.homepage         = "https://github.com/393385724/DDWebService.git"  
  s.license          = 'MIT'  
  s.author           = { "llg" => "393385724@qq.com" }  
  s.source           = { :git => "https://github.com/393385724/DDWebService.git", :tag => s.version.to_s }  
  
  s.platform     = :ios, '8.0'  
  s.requires_arc = true 
  
  s.source_files  = 'DDWebServie/Auxfun/*.{h,m}','DDWebServie/Client/*.{h,m}','DDWebServie/Task/*.{h,m}'
  s.frameworks    = 'Foundation', 'UIKit'
  s.dependency 'AFNetworking'
end  
