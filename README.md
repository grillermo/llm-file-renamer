# Why?

If you want to rename a bunch of files that have different shapes and you don't really want to find the right heuristics for all the renames but also don't want to pay an external service like OpenAI to perform these changes. A local LLM is perfect, you can even use the smaller models. I had success with gemma3:12b that runs decently well on an M2 16GB RAM mac.

# How to use it

1. Clone this repo.
2. Run Ollama.
2. Modify the PROMPT inside the rename_files function to suite your needs.
3. Call the rename_files.rb script like this
 ```ruby
 ruby rename_files.rb '/path/to/your-files' --model 'gemma3:12b' --ollama-url http://localhost:11434
 ```
4. Enjoy