Pod::Spec.new do |s|
  s.name             = 'SwimpleNetwork'
  s.version          = '1.0.0'
  s.summary          = 'Simple networking in Swift.'

  s.description      = 'SwimpleNetwork is part of the Swimple packages series. Swimple stands for Simple Swift. These packages make coding with Swift simpler and more convenient.'

  s.homepage         = 'https://github.com/lloydkeijzer/SwimpleNetwork'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lloyd Keijzer' => 'contact@lloydkeijzer.nl' }
  s.source           = { :git => 'https://github.com/lloydkeijzer/SwimpleNetwork.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/lloyd_keijzer'

  s.ios.deployment_target = '10.0'

  s.source_files = 'Sources/SwimpleNetwork/**/*'
  s.dependency 'Alamofire', '~> 5.0'
end
