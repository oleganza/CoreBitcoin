#!/usr/bin/env ruby

header_comment = %{// CoreBitcoin by Oleg Andreev <oleganza@gmail.com>, WTFPL.}

header_filenames = []
header_ext_filenames = []

# Collect all headers and update their license/authorship notices.
Dir.glob("CoreBitcoin/**/*.h").each do |header_filename|
  name = header_filename.gsub("CoreBitcoin/", "")
  if !name["CoreBitcoin"] && !name["+Tests"]
    if name["+"]
      header_ext_filenames << header_filename
    else
      header_filenames << header_filename
    end
  end
  
  data = File.read(header_filename)
  
  # Update first line with an authorship comment.
  
  data.gsub!(%r{\A(//[^\n]+\n)+\n}mi, header_comment + "\n\n")
  if !data[header_comment]
    data = header_comment + "\n\n" + data
  end

  if false
    puts "------- BEGIN FILE #{header_filename} ----------" 
  
    puts data
  
    puts "------- END FILE #{header_filename} ----------" 
    puts ""
  end
  
  File.open(header_filename, "w"){|f| f.write data }
end

# Update combined headers

File.open("CoreBitcoin/CoreBitcoin.h", "w") do |f|
  f.write(header_comment + "\n\n")
  header_filenames.each do |path|
    f.write("#import <#{path}>\n")
  end
end

File.open("CoreBitcoin/CoreBitcoin+Categories.h", "w") do |f|
  f.write(header_comment + "\n\n")
  f.write("#import <CoreBitcoin/CoreBitcoin.h>\n")
  header_ext_filenames.each do |path|
    f.write("#import <#{path}>\n")
  end
end

