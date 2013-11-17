Pod::Spec.new do |s|
  s.name         = "CoreBitcoin"
  s.version      = "0.1.0"
  s.summary      = "CoreBitcoin is an implementation of Bitcoin protocol in Objective-C."
  s.description  = <<-DESC
                   CoreBitcoin is an implementation of Bitcoin protocol in Objective-C.
                   When it is completed, it will let you create an application that acts
                   as a full Bitcoin node. You can encode/decode addresses, apply various
                   hash functions, sign and verify messages and parse some data structures.
                   Transaction support is still incomplete.
                   DESC
  s.homepage     = "https://github.com/oleganza/CoreBitcoin"
  s.license      = 'WTFPL'
  s.author       = { "Oleg Andreev" => "oleganza@gmail.com" }
  s.platform     = :osx, '10.9'
  s.source       = { :git => "https://github.com/oleganza/CoreBitcoin.git", :branch => "master", :tag => "0.1.0" }
  s.source_files = 'CoreBitcoin', 'openssl/include/openssl/*.h'
  s.libraries    = 'libcrypto', 'libssl'
  s.requires_arc = true
  s.xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(SRCROOT)/CoreBitcoin/openssl/include',
    'LIBRARY_SEARCH_PATHS' => '$(SRCROOT)/CoreBitcoin/openssl/lib'
  }
end
