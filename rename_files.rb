#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'
require_relative 'lib/ollama/client'


# Function to generate new filename using LLM
def rename_file(original_name, model: ,ollama_url: )
  basename = File.basename(original_name, ".*")
  extname = File.extname(original_name)
  
  prompt = <<~PROMPT
    Extract the date from this filename and format it as "Month Year" (e.g., "January 2024").
    The filename may contain Spanish month names (enero, febrero, marzo, abril, mayo, junio, julio, agosto, septiembre, octubre, noviembre, diciembre).
    Convert Spanish months to English and format as "Month Year".
    
    Filename: #{basename}
    
    Return ONLY the formatted date in the format "YYYY-MM-DD" (e.g., "2024-12-23", "2024-02-13").
    If no date can be extracted, return "INVALID".
  PROMPT

  llm_response = query_ollama(prompt, model: , base_url: ollama_url)
  
  if llm_response && llm_response != "INVALID" && !llm_response.empty?
    # Clean up the response - remove any extra text, quotes, etc.
    formatted_date = llm_response.gsub(/['"]/, '').strip
    
    # Validate it looks like "Month Year" format
    if formatted_date.match?(/^\d{4}-\d{2}-\d{2}$/)
      formatted_date + extname
    else
      puts "Warning: LLM returned unexpected format: #{llm_response}. Using original name."
      original_name
    end
  else
    puts "Warning: Could not extract date from '#{original_name}'. Using original name."
    original_name
  end
end

# Main function to process files
def process_files(path, model: , ollama_url: "http://localhost:11434")
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
    original_path = File.join(path, original_name)

    new_name = rename_file(original_name, model: model, ollama_url: ollama_url) 
    new_path = File.join(path, new_name)
    
    # Skip if the new name is the same as the original
    if original_name == new_name
      puts "Skipping '#{original_name}' (no change needed)"
      next
    end
    
    # Check if target file already exists
    if File.exist?(new_path)
      puts "Warning: Target file '#{new_name}' already exists. Skipping '#{original_name}'"
      next
    end
    
    # Perform the actual rename
    begin
      File.rename(original_path, new_path)
      puts "Renamed: #{original_name} -> #{new_name}"
    rescue => e
      puts "Error renaming '#{original_name}': #{e.message}"
    end
  end
end

# CLI entry point
if __FILE__ == $0
  model = ARGV.include?('--model') ? ARGV[ARGV.index('--model') + 1] : "llama3.2"
  ollama_url = ARGV.include?('--ollama-url') ? ARGV[ARGV.index('--ollama-url') + 1] : "http://localhost:11434"
  
  # Remove flags and their values from ARGV to get the path
  path_args = ARGV.reject.with_index { |arg, i| 
    (arg == '--model' && ARGV[i + 1]) ||
    (arg == '--ollama-url' && ARGV[i + 1]) ||
    (i > 0 && (ARGV[i - 1] == '--model' || ARGV[i - 1] == '--ollama-url'))
  }
  
  if path_args.length != 1
    puts "Example: #{$0} /path/to/directory"
    puts "Example (custom model): #{$0} /path/to/directory --model llama3.2"
    exit 1
  end

  path = path_args[0]
  process_files(path, model: model, ollama_url: ollama_url)
end

