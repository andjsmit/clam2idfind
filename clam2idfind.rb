#!/usr/bin/env ruby

require 'optparse'
require 'shellwords'

# Methods

def diff_files(previous, current)
  # Return array of files from diff of two clam scans
  cmd = "diff #{previous} #{current} | grep -Po '(?<=(>)).*(?=: Heuristics)'"
  files = `#{cmd}`.split("\n")
end

def current_files(current)
  # Return array of file names from clam scan
  cmd = "cat #{current} | grep -Po '.*(?=: Heuristics)'"
  files = `#{cmd}`.split("\n")
end

def list_files(files)
  # Print list of files
  files.each do |filename|
    puts "#{filename}"
  end
end

def copy_files(files, destination)
  # Copy given file to destination
  # Return number of files copied
  copy_count = 0
  files.each do |filename|
    shellname = Shellwords.shellescape filename.strip
    cmd = "cp #{shellname} #{destination}"
    if `#{cmd}` == 0
      ++copy_count
    end
  end
  copy_count
end

# Main Program

options = {}

OptionParser.new do |parser|
  parser.banner = "Usage: clam2idfind [options]"

  parser.on("-p", "--previous-scan PREVIOUS", "The old scanned file.") do |v|
    options[:previous] = v
  end

  parser.on("-c", "--current-scan CURRENT", "The new scanned file.") do |v|
    options[:current] = v
  end

  parser.on("-d", "--destination DESTINATION", "Destination of copied files, else files will be listed.") do |v|
    options[:destination] = v
  end

  parser.on("-h", "--help", "Show this help message.") do ||
    puts parser
    exit
  end

end.parse!

#puts "old file = #{options[:previous]}. New file = #{options[:current]}"

if options[:previous] && options[:current]
  files = diff_files(options[:previous], options[:current])
  if options[:destination]
    count = copy_files(files, options[:destination])
    puts "#{files.count} files found."
    puts "#{count} file copied."
  else
    list_files(files)
    puts "#{files.count} files found."
  end
elsif options[:current]
  files = current_files(options[:current])
  current_files(options[:current])
  if options[:destination]
    count = copy_files(files, options[:destination])
    puts "#{files.count} files found."
    puts "#{count} files copied."
  else
    list_files(files)
    puts "#{files.count} files found."
  end
else
  puts "No files given. See --help for details."
end
