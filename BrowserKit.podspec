Pod::Spec.new do |s|
  s.name             = 'BrowserKit'
  s.version          = '0.1.0'
  s.summary          = 'BrowserKit'

  s.description      = <<-DESC
BrowserKit
                       DESC

  s.homepage         = 'https://github.com/chanjh/BrowserKit'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'UgCode' => 'jiahao0408@gmail.com' }
  s.source           = { :git => 'https://github.com/chanjh/BrowserKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'

  s.source_files = 'BrowserKit/**/*{swift,h,m}'
  s.swift_versions = '5.0'
  
  s.dependency 'SnapKit', '~> 5.0.0'
  s.dependency 'GCWebContainer', '~> 0.1.0'
  s.dependency 'Pandora', '~> 0.1.0'
  s.dependency 'Tiercel'
end