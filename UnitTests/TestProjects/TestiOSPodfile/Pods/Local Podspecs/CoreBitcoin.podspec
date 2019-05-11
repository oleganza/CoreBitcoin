Pod::Spec.new do |s|
  s.name         = "EthCore"
  s.version      = "0.1.0"
  s.summary      = "EthCore is an implementation of Bitcoin protocol in Objective-C."
  s.description  = <<-DESC
                   EthCore is an implementation of Bitcoin protocol in Objective-C.
                   When it is completed, it will let you create an application that acts
                   as a full Bitcoin node. You can encode/decode addresses, apply various
                   hash functions, sign and verify messages and parse some data structures.
                   Transaction support is still incomplete.
                   DESC
  s.homepage     = "https://github.com/oleganza/EthCore"
  s.license      = 'WTFPL'
  s.author       = { "Oleg Andreev" => "oleganza@gmail.com" }
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.source       = { :git => "https://github.com/oleganza/EthCore.git" }
  s.source_files = 'EthCore'
  s.exclude_files = 'EthCore/**/*+Tests.{h,m}'
  s.requires_arc = true
  s.framework    = 'Foundation'
  s.dependency 'OpenSSL', '~> 1.0.1'
end
