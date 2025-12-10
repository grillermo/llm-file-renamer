#!/usr/bin/env ruby
require 'active_support/all'
require 'chronic'
require 'pry'
require 'date_core'

SPANISH_TO_ENGLISH_MONTH_NAMES = {
  "enero" => "january",
  "febrero" => "february",
  "marzo" => "march",
  "abril" => "april",
  "mayo" => "may",
  "junio" => "june",
  "julio" => "july",
  "agosto" => "august",
  "septiembre" => "september",
  "setiembre" => "september",
  "octubre" => "october",
  "noviembre" => "november",
  "diciembre" => "december"
  }


def replace_spanish_months_to_english_in_string(string)
  SPANISH_TO_ENGLISH_MONTH_NAMES.each do |spanish, english|
    string = string.downcase.gsub(/#{spanish}/i, english)
  end
  string
end

def with_chronic(possible_date)
  Chronic.parse(possible_date)
end

def with_DateTime(possible_date)
  DateTime.parse(possible_date.gsub('-',' '))
rescue Date::Error
  nil
end

def format_new_date(original_name, extname)
  original_name.strftime("%B %Y") + extname
end

# Function to generate new filename
def rename_function(original_name)
  translated_names = replace_spanish_months_to_english_in_string(original_name)
  # Example: Add "renamed_" prefix
  # You can modify this function to implement different renaming logic
  basename = File.basename(translated_names, ".*")
  extname = File.extname(translated_names)

  if chronic_attempt = with_chronic(basename)
    format_new_date(chronic_attempt, extname)
  elsif dateTime_attempt = with_DateTime(basename)
    format_new_date(dateTime_attempt, extname)
  else
    original_name
  end
end

# Main function to process files
def process_files(path)
  unless Dir.exist?(path)
    puts "Error: Path '#{path}' does not exist or is not a directory"
    exit 1
  end

  files = Dir.entries(path).select { |f| File.file?(File.join(path, f)) }
  
  if files.empty?
    puts "No files found in '#{path}'"
    return
  end

  files.each do |file|
    original_name = file
    new_name = rename_function(original_name)
    
    puts "Original: #{original_name} -> New: #{new_name}"
  end
end

# CLI entry point
if __FILE__ == $0
  if ARGV.length != 1
    puts "Usage: #{$0} <path>"
    puts "Example: #{$0} /path/to/directory"
    exit 1
  end

  path = ARGV[0]
  process_files(path)
end

