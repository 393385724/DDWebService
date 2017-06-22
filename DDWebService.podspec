Pod::Spec.new do |s|  
  s.name             = "DDWebService"  
  s.version          = "2.0.0"  
  s.summary          = "A WebService with AFNetWorking"  
  s.homepage         = "https://github.com/393385724/DDWebService.git"  
  s.license          = 'MIT'  
  s.author           = { "llg" => "393385724@qq.com" }  
  s.source           = { :git => "https://github.com/393385724/DDWebService.git", :tag => s.version.to_s }  
  
  s.platform     = :ios, '8.0'  
  s.requires_arc = true 
  
  s.source_files  = 'DDWebService/Auxfun/*.{h,m}','DDWebService/Client/*.{h,m}','DDWebService/Task/*.{h,m}'
  s.frameworks    = 'Foundation', 'UIKit'
  s.dependency 'AFNetworking'
end  
