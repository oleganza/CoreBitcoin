Pod::Spec.new do |s|
  s.name         = "CoreBitcoin"
  s.version      = "0.0.1"
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
  s.platform     = :osx, '10.8'
  s.source       = { :git => "https://github.com/knickmack/CoreBitcoin.git", :tag => "0.0.1" }
  s.source_files  = 'CoreBitcoin'

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = 'SomeFramework'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'

  # s.library   = 'iconv'
  # s.libraries = 'iconv', 'xml2'


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
  # s.dependency 'JSONKit', '~> 1.4'

end
