#!/usr/bin/env ruby

framework_path = ARGV[0] || "binaries/**/EthCore.framework"

Dir.glob("#{framework_path}/**/*.h").each do |src|
  # puts "REWRITING INCLUDES IN #{src}"
  
  data = File.read(src)
  
  #include <openssl/bn.h> => #include <EthCore/openssl/bn.h>
  data.gsub!(%r{#(include|import) <openssl/}, "#\\1 <EthCore/openssl/")
  
  #import "BTCSignatureHashType.h" => #import <EthCore/BTCSignatureHashType.h> 
  data.gsub!(%r{#(include|import) "(BTC.*?\.h)"}, "#\\1 <EthCore/\\2>")
  
  File.open(src, "w"){|f| f.write(data)}
end
