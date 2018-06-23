Pod::Spec.new do |s|
  s.name         = "CoreBitcoin"
  s.version      = "0.6.8.1"
  s.summary      = "CoreBitcoin is an implementation of Bitcoin protocol in Objective-C."
  s.description  = <<-DESC
                   CoreBitcoin is a complete toolkit to work with Bitcoin data structures.
                   DESC
  s.homepage     = "https://github.com/wjmelements/CoreBitcoin"
  s.license      = 'WTFPL'
  s.author       = { "Oleg Andreev" => "oleganza@gmail.com" }
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.source       = { :git => "https://github.com/oleganza/CoreBitcoin.git", :tag => s.version.to_s }
  s.source_files = 'CoreBitcoin', 'openssl'
  s.exclude_files = ['CoreBitcoin/**/*+Tests.{h,m}', 'CoreBitcoin/BTCScriptTestData.h']
  s.requires_arc = true
  s.xcconfig = { 'USER_HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/openssl/include"', '"${PODS_ROOT}/openssl/src/**"' }
  s.framework    = 'Foundation'
  s.dependency 'ISO8601DateFormatter'
end
