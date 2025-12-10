require 'net/http'
require 'json'
require 'uri'

# Function to generate new filename
# LLM-based version using Ollama
def query_ollama(prompt, model: , base_url: "http://localhost:11434")
    uri = URI("#{base_url}/api/generate")
    
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = {
      model: model,
      prompt: prompt,
      stream: false
    }.to_json
  
    begin
      response = http.request(request)
      if response.code == '200'
        result = JSON.parse(response.body)
        result['response']&.strip
      else
        puts "Error: Ollama API returned status #{response.code}"
        nil
      end
    rescue => e
      puts "Error connecting to Ollama: #{e.message}"
      puts "Make sure Ollama is running at #{base_url}"
      nil
    end
  end