Pod::Spec.new do |s|
  s.name         = "CoreEthereum"
  s.version      = "1.0.4"
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
  s.user_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/openssl/include" "${PODS_ROOT}/CoreEthereum/openssl/include"',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
  }
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/openssl/include" "${PODS_ROOT}/CoreEthereum/openssl/include"',
    'USER_HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/openssl/src/**" "${PODS_ROOT}/CoreEthereum/openssl/src/**"',
    'OTHER_CFLAGS' => '$(inherited) -DOPENSSL_NO_SEED -DOPENSSL_NO_IDEA -DOPENSSL_NO_RC2 -DOPENSSL_NO_RC4 -DOPENSSL_NO_DES -DOPENSSL_NO_SM4 -DOPENSSL_NO_SM4 -DOPENSSL_NO_BF -DOPENSSL_NO_CHACHA'
  }
  s.framework    = 'Foundation'
  s.preserve_paths = 'openssl/LICENSE', 'openssl/**/*.h'
  s.dependency 'ISO8601DateFormatter'
end
