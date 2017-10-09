Pod::Spec.new do |s|
  s.name         = "DWMusic"
  s.version      = "0.2.0"
  s.summary      = "基于rxswift开发的音乐播放器"
  s.description  = <<-EOS
  基于rxswift开发的音乐播放器,功能将不断添加和完善。

  EOS
  s.homepage     = "https://github.com/danwey/DWMusic"
  s.license      = { :type => "MIT", :file => "License.md" }
  s.author             = { "danwey" => "509070768@qq.com" }
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.source       = { :git => "https://github.com/danwey/DWMusic.git", :tag => s.version }
  s.default_subspec = "Core"
  s.resource_bundle = { s.name => [
    'DWMusic/Resources/*.{png,jpg}',
    'DWMusic/Sources/**/*.{storyboard,xib}',
    'DWMusic/Sources/*.{storyboard,xib}'
    ] }
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

  s.subspec "Core" do |ss|
    ss.source_files  = "DWMusic/Sources/"
    ss.dependency 'RxSwift' , '~> 4.0.0-alpha.1'
    ss.dependency 'RxCocoa' , '~> 4.0.0-alpha.1'
    ss.dependency 'SwiftyJSON', '~> 4.0.0-alpha.1'
    ss.dependency 'Kingfisher', '~> 4.0.1'
    ss.dependency 'SnapKit', '~> 4.0.0'
    ss.framework  = "Foundation"
  end

end
