Pod::Spec.new do |s|
  s.name         = "EthCore"
  s.version      = "1.0.7"
  s.summary      = "EthCore is a subset of CoreBitcoin in Objective-C."
  s.description  = <<-DESC
                   EthCore provides helpful functions for deriving and signing with Ethereum keychains.
                   DESC
  s.homepage     = "https://github.com/wjmelements/EthCore"
  s.license      = 'WTFPL'
  s.author       = { "William Morriss" => "wjmelements@gmail.com" }
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.source       = { :git => "https://github.com/wjmelements/EthCore.git", :tag => s.version.to_s }
  s.source_files = 'EthCore', 'openssl/**/*.c', 'openssl/include/**/*.h'
  s.exclude_files = ['EthCore/**/*+Tests.{h,m}', 'EthCore/BTCScriptTestData.h']
  s.public_header_files = 'EthCore/*.h', 'openssl/include/openssl/*.h'
  s.private_header_files = 'openssl/include/internal/*.h'
  s.header_mappings_dir = '.'
  s.requires_arc = true
  s.user_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/openssl/include" "${PODS_ROOT}/EthCore/openssl/include"',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
  }
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/openssl/include" "${PODS_ROOT}/EthCore/openssl/include"',
    'USER_HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/openssl/src/**" "${PODS_ROOT}/EthCore/openssl/src/**"',
    'OTHER_CFLAGS' => '$(inherited) -DOPENSSL_NO_SEED -DOPENSSL_NO_IDEA -DOPENSSL_NO_RC2 -DOPENSSL_NO_RC4 -DOPENSSL_NO_DES -DOPENSSL_NO_SM4 -DOPENSSL_NO_SM4 -DOPENSSL_NO_BF -DOPENSSL_NO_CHACHA -DOPENSSL_NO_ASYNC'
  }
  s.framework    = 'Foundation'
  s.preserve_paths = 'openssl/LICENSE', 'openssl/**/*.h'
  s.dependency 'ISO8601DateFormatter'
end
