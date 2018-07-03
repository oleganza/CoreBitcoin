Pod::Spec.new do |s|
  s.name         = "CoreEthereum"
  s.version      = "1.0.0"
  s.summary      = "CoreEthereum is a subset of CoreBitcoin in Objective-C."
  s.description  = <<-DESC
                   CoreEthereum provides helpful functions for deriving and signing with Ethereum keychains.
                   DESC
  s.homepage     = "https://github.com/wjmelements/CoreBitcoin"
  s.license      = 'WTFPL'
  s.author       = { "Oleg Andreev" => "oleganza@gmail.com" }
  s.author       = { "William Morriss" => "william.morriss@consensys.net" }
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.source       = { :git => "https://github.com/wjmelements/CoreBitcoin.git", :tag => s.version.to_s }
  s.source_files = 'CoreBitcoin', 'openssl/**/*.c', 'openssl/include/**/*.h'
  s.exclude_files = ['CoreBitcoin/**/*+Tests.{h,m}', 'CoreBitcoin/BTCScriptTestData.h']
  s.public_header_files = 'CoreBitcoin/*.h', 'openssl/include/openssl/*.h'
  s.private_header_files = 'openssl/include/internal/*.h'
  s.header_mappings_dir = '.'
  s.requires_arc = true
  s.xcconfig = {
    'HEADER_SEARCH_PATHS' => '${PODS_TARGET_SRCROOT}/openssl/include',
    'USER_HEADER_SEARCH_PATHS' => '${PODS_TARGET_SRCROOT}/openssl/src/**'
  }
  s.framework    = 'Foundation'
  s.preserve_paths = 'openssl/LICENSE', 'openssl/**/*.h'
  s.dependency 'ISO8601DateFormatter'
end
