#!/usr/bin/env ruby

framework_path = ARGV[0] || "binaries/**/CoreBitcoin.framework"

Dir.glob("#{framework_path}/**/*.h").each do |src|
  # puts "REWRITING INCLUDES IN #{src}"
  
  data = File.read(src)
  
  #include <openssl/bn.h> => #include <CoreBitcoin/openssl/bn.h>
  data.gsub!(%r{#(include|import) <openssl/}, "#\\1 <CoreBitcoin/openssl/")
  
  #import "BTCSignatureHashType.h" => #import <CoreBitcoin/BTCSignatureHashType.h> 
  data.gsub!(%r{#(include|import) "(BTC.*?\.h)"}, "#\\1 <CoreBitcoin/\\2>")
  
  File.open(src, "w"){|f| f.write(data)}
end
