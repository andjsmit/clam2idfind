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
    `cp #{shellname} #{destination}`
    copy_count += 1 if $?.success?
  end
  copy_count
end

# Options

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

# Main Program

files = Array.new
list_head = ''
list_idfind   = "\n\n***************\n"
list_idfind  += "Identity Finder\n"
list_idfind  += "***************\n\n"
list_idfind  += "Files scanned with Identity Finder (yes/no) ?\n\n"
list_idfind  += "Files scanned with Identity Finder\n"
list_idfind  += "that tested positive for sensitive data\n"
list_idfind  += "***************************************\n\n"
list_idfind  += "None\n\n"
list_idfind  += "Files that did contain sensitive data\n"
list_idfind  += "***************************************\n\n"
list_idfind  += "None\n\n"
list_idfind  += "Actions taken\n"
list_idfind  += "*************\n\n"
list_idfind  += "None\n\n"

if options[:previous] && options[:current]
  files = diff_files(options[:previous], options[:current])
  list_head  = "ClamAV DLP Scan New files between:\n"
  list_head += "**********************************\n"
  list_head += "Previous : #{options[:previous]}\n"
  list_head += "Current  : #{options[:current]}\n\n\n"
elsif options[:current]
  files = current_files(options[:current])
  list_head  = "ClamAV DLP Scan for file:\n"
  list_head += "*************************\n"
  list_head += "File: #{options[:current]}\n\n\n"
else
  puts "No files given. See --help for details."
  exit
end

if options[:destination]
  puts "#{files.count} files found."
  count = copy_files(files, options[:destination])
  puts "#{count} files copied."
else
  puts list_head
  list_files(files)
  puts "#{files.count} files found."
  puts list_idfind
end
